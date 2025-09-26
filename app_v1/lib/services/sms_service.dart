import 'package:flutter/foundation.dart';
import '../models/collection_event.dart';
import '../config/app_config.dart';
import 'local_storage_service.dart';
import 'sync_service.dart';

class SMSService {
  static SMSService? _instance;
  static SMSService get instance => _instance ??= SMSService._();
  
  SMSService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;
  final SyncService _syncService = SyncService.instance;

  Future<bool> requestSMSPermissions() async {
    // SMS functionality disabled - always return false
    if (kDebugMode) {
      print('SMS functionality is disabled');
    }
    return false;
  }

  Future<bool> canSendSMS() async {
    // SMS functionality disabled
    return false;
  }

  Future<SMSResult> sendCollectionEventSMS(CollectionEvent event) async {
    if (kDebugMode) {
      print('SMS functionality disabled - would have sent: ${event.generateSMSPayload()}');
      print('Target number would have been: ${AppConfig.smsGatewayNumber}');
    }
    
    return SMSResult(
      success: false,
      error: 'SMS functionality is disabled',
    );
  }

  Future<SMSResult> sendAllQueuedSMS() async {
    final queuedEvents = await _syncService.getSMSQueuedEvents();
    
    if (kDebugMode) {
      print('SMS functionality disabled - would have sent ${queuedEvents.length} queued events');
    }
    
    return SMSResult(
      success: false,
      message: 'SMS functionality is disabled',
      failedCount: queuedEvents.length,
    );
  }

  Future<void> setupSMSListener() async {
    if (kDebugMode) {
      print('SMS service initialized (functionality disabled)');
    }
  }

  Future<String> generateSMSStatusReport() async {
    final queuedEvents = await _syncService.getSMSQueuedEvents();
    
    return '''
SMS Status Report (SMS Disabled):
- Queued for SMS: ${queuedEvents.length}
- SMS functionality is currently disabled
''';
  }
}

class SMSResult {
  final bool success;
  final String? error;
  final String? message;
  final int? messageCount;
  final int? sentCount;
  final int? failedCount;
  final List<String>? errors;

  SMSResult({
    required this.success,
    this.error,
    this.message,
    this.messageCount,
    this.sentCount,
    this.failedCount,
    this.errors,
  });
}
