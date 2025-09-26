import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/collection_event.dart';
import '../config/app_config.dart';
import 'local_storage_service.dart';
import 'http_client_service.dart';

class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  
  SyncService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;
  final HttpClientService _httpClient = HttpClientService.instance;
  bool _isSyncing = false;

  Future<bool> isOnline() async {
    try {
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.first == ConnectivityResult.none) {
        if (kDebugMode) {
          print('No network connectivity detected');
        }
        return false;
      }

      // For web and development, try to connect to our backend health endpoint
      final healthUrl = AppConfig.getApiUrl(AppConfig.healthEndpoint);
      
      if (kDebugMode) {
        print('Checking server health at: $healthUrl');
      }

      return await _httpClient.checkConnectivity(healthUrl);
      
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity check error: $e');
      }
      // For web development, return true to allow testing
      return kIsWeb;
    }
  }

  Future<SyncResult> syncCollectionEvent(CollectionEvent event) async {
    try {
      if (kDebugMode) {
        print('Starting sync for event: ${event.eventId}');
      }
      
      // Mock mode for testing without backend
      if (AppConfig.enableMockMode) {
        if (kDebugMode) {
          print('Mock mode enabled - simulating successful sync');
        }
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        await _localStorage.updateCollectionEventSyncStatus(
          event.eventId, 
          SyncStatus.synced,
        );
        
        return SyncResult(success: true, message: 'Event synced successfully (mock mode)');
      }
      
      if (!await isOnline()) {
        if (kDebugMode) {
          print('Sync failed: No internet connection - queuing for SMS');
        }
        
        // Automatically queue for SMS when offline
        if (AppConfig.enableSMSFallback) {
          await queueForSMSTransmission(event);
          return SyncResult(
            success: false,
            error: 'No internet connection - event queued for SMS transmission',
            shouldRetry: true,
          );
        }
        
        return SyncResult(
          success: false,
          error: 'No internet connection or server unavailable',
          shouldRetry: true,
        );
      }

      if (kDebugMode) {
        print('Internet connection available, proceeding with sync');
      }
      
      await _localStorage.updateCollectionEventSyncStatus(
        event.eventId, 
        SyncStatus.syncing,
      );

      final apiUrl = AppConfig.getApiUrl(AppConfig.collectionEndpoint);
      if (kDebugMode) {
        print('Sending POST request to: $apiUrl');
      }

      final response = await _httpClient.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add CORS headers for web
          if (kIsWeb) ...{
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
          },
        },
        body: event.toJson(),
      );

      if (kDebugMode) {
        print('Sync response: ${response.statusCode} - ${response.body}');
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _localStorage.updateCollectionEventSyncStatus(
          event.eventId, 
          SyncStatus.synced,
        );
        
        return SyncResult(success: true, message: 'Event synced successfully');
      } else {
        await _localStorage.updateCollectionEventSyncStatus(
          event.eventId, 
          SyncStatus.failed,
        );
        
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['error'] ?? errorMessage;
        } catch (e) {
          // Use default error message if JSON parsing fails
        }
        
        // Queue for SMS if server error and SMS fallback is enabled
        if (AppConfig.enableSMSFallback && response.statusCode >= 400) {
          await queueForSMSTransmission(event);
          errorMessage += ' - event queued for SMS transmission';
        }
        
        return SyncResult(
          success: false,
          error: errorMessage,
          shouldRetry: response.statusCode >= 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync exception: $e');
      }
      
      await _localStorage.updateCollectionEventSyncStatus(
        event.eventId, 
        SyncStatus.failed,
      );
      
      String errorMessage = _getErrorMessage(e);
      
      // Queue for SMS if network error and SMS fallback is enabled
      if (AppConfig.enableSMSFallback && _shouldRetryError(e)) {
        await queueForSMSTransmission(event);
        errorMessage += ' - event queued for SMS transmission';
      }
      
      return SyncResult(
        success: false,
        error: errorMessage,
        shouldRetry: _shouldRetryError(e),
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('Failed to fetch') || errorStr.contains('ClientException')) {
      return 'Cannot connect to server. Please ensure:\n'
          '1. Backend server is running on localhost:3001\n'
          '2. CORS is properly configured\n'
          '3. Try running Flutter with: flutter run -d chrome --web-browser-flag "--disable-web-security"';
    } else if (errorStr.contains('Failed host lookup')) {
      return 'Cannot connect to server. Please check if backend is running on localhost:3001';
    } else if (errorStr.contains('Connection refused')) {
      return 'Server connection refused. Backend may not be running on port 3001';
    } else if (errorStr.contains('TimeoutException')) {
      return 'Request timed out. Server may be slow or unreachable';
    } else if (errorStr.contains('FormatException')) {
      return 'Invalid server response format';
    } else {
      return 'Sync failed: $errorStr';
    }
  }

  bool _shouldRetryError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('TimeoutException') ||
           errorStr.contains('SocketException') ||
           errorStr.contains('ClientException') ||
           errorStr.contains('Failed to fetch');
  }

  Future<SyncResult> syncAllPendingEvents() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        error: 'Sync already in progress',
        shouldRetry: false,
      );
    }

    _isSyncing = true;
    
    try {
      final pendingEvents = await _localStorage.getPendingSyncEvents();
      
      if (pendingEvents.isEmpty) {
        return SyncResult(success: true, message: 'No events to sync');
      }

      if (kDebugMode) {
        print('Starting sync for ${pendingEvents.length} pending events');
      }

      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      for (final event in pendingEvents) {
        final result = await syncCollectionEvent(event);
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
          errors.add('${event.eventId}: ${result.error}');
        }
        
        // Small delay between requests to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return SyncResult(
        success: failureCount == 0,
        message: 'Synced $successCount events, $failureCount failed',
        syncedCount: successCount,
        failedCount: failureCount,
        errors: errors,
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<CollectionEvent>> fetchCollectionHistory(String collectorId) async {
    try {
      if (!await isOnline()) {
        // Return local data if offline
        return await _localStorage.getCollectionEventsByCollector(collectorId);
      }

      final historyUrl = '${AppConfig.baseUrl}/collector/$collectorId/history';
      
      final response = await _httpClient.get(historyUrl, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final events = data.map((json) => CollectionEvent.fromJson(json)).toList();
        
        // Update local storage with server data
        for (final event in events) {
          await _localStorage.saveCollectionEvent(event);
        }
        
        return events;
      } else {
        // Fallback to local data
        return await _localStorage.getCollectionEventsByCollector(collectorId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch history: $e');
      }
      // Fallback to local data
      return await _localStorage.getCollectionEventsByCollector(collectorId);
    }
  }

  Future<void> schedulePeriodicSync() async {
    // This would typically be implemented with a background service
    // For now, we'll just sync when the app is active
    while (true) {
      await Future.delayed(Duration(minutes: AppConfig.periodicSyncIntervalMinutes));
      
      if (await isOnline()) {
        final result = await syncAllPendingEvents();
        if (kDebugMode) {
          print('Periodic sync result: ${result.message}');
        }
      }
    }
  }

  Future<String?> _getAuthToken() async {
    // Implement your authentication token retrieval logic
    // This could be from SharedPreferences, secure storage, etc.
    return _localStorage.getSetting<String>('auth_token');
  }

  // SMS Fallback functionality
  Future<void> queueForSMSTransmission(CollectionEvent event) async {
    final smsPayload = event.generateSMSPayload();
    final updatedEvent = event.copyWith(
      syncStatus: SyncStatus.smsQueued,
      smsPayload: smsPayload,
    );
    
    await _localStorage.saveCollectionEvent(updatedEvent);
    
    if (kDebugMode) {
      print('Event queued for SMS: ${event.eventId}');
    }
  }

  Future<List<CollectionEvent>> getSMSQueuedEvents() async {
    return await _localStorage.getSMSQueuedEvents();
  }

  Future<void> markSMSAsSent(String eventId) async {
    await _localStorage.updateCollectionEventSyncStatus(eventId, SyncStatus.smsSent);
  }

  // Health check with better error handling
  Future<bool> checkServerHealth() async {
    try {
      final healthUrl = AppConfig.getApiUrl(AppConfig.healthEndpoint);
      
      if (kDebugMode) {
        print('Checking server health: $healthUrl');
      }

      final response = await _httpClient.get(healthUrl);
      
      if (response.statusCode == 200) {
        final health = jsonDecode(response.body);
        if (kDebugMode) {
          print('Server health: ${health['status']}');
        }
        return health['status'] == 'healthy';
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Health check failed: $e');
      }
      return false;
    }
  }

  // Force sync all data (useful for testing)
  Future<SyncResult> forceSyncAll() async {
    try {
      final allEvents = await _localStorage.getAllCollectionEvents();
      
      // Reset all to pending status
      for (final event in allEvents) {
        await _localStorage.updateCollectionEventSyncStatus(
          event.eventId, 
          SyncStatus.pending,
        );
      }
      
      return await syncAllPendingEvents();
    } catch (e) {
      return SyncResult(
        success: false,
        error: 'Force sync failed: ${e.toString()}',
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String? error;
  final String? message;
  final bool shouldRetry;
  final int? syncedCount;
  final int? failedCount;
  final List<String>? errors;

  SyncResult({
    required this.success,
    this.error,
    this.message,
    this.shouldRetry = false,
    this.syncedCount,
    this.failedCount,
    this.errors,
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, error: $error, shouldRetry: $shouldRetry)';
  }
}