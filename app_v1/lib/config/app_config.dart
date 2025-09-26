import 'package:flutter/foundation.dart';

class AppConfig {
  // Backend Configuration - detect environment
  static String get baseUrl {
    // Check if running on web
    if (kIsWeb) {
      // For Flutter Web, use the current host or localhost
      if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
        return 'http://localhost:3001/api';
      } else {
        // Production URL
        return 'https://your-production-domain.com/api';
      }
    } else {
      // Mobile/Desktop - use localhost for development
      return 'http://localhost:3001/api';
    }
  }
  
  static const String websiteUrl = 'http://localhost:3001';
  
  // Rest of your configuration remains the same...
  static const String collectionEndpoint = '/collections';
  static const String historyEndpoint = '/collector';
  static const String healthEndpoint = '/health';
  static const String authEndpoint = '/auth';
  
  // SMS Configuration
  static const String smsGatewayNumber = '8248194419'; // SMS number for offline mode
  static const int smsMaxLength = 140;
  
  // App Configuration
  static const String appName = 'AyurTrack Collector';
  static const String appVersion = '1.0.0';
  
  // Local Storage Configuration
  static const String collectionEventsBox = 'collection_events';
  static const String settingsBox = 'settings';
  
  // Sync Configuration - adjust timeouts for web
  static const int syncRetryAttempts = 3;
  static const int syncTimeoutSeconds = 60; // Increased timeout for web
  static const int periodicSyncIntervalMinutes = 5;
  
  // Quality Metrics Configuration
  static const int qualityMinRating = 1;
  static const int qualityMaxRating = 10;
  static const int qualityDefaultRating = 5;
  
  // GPS Configuration
  static const double gpsAccuracyThreshold = 50.0; // meters
  static const int gpsTimeoutSeconds = 30;
  
  // UI Configuration
  static const int historyPageSize = 50;
  static const int maxSearchResults = 100;
  
  // Development/Debug flags
  static const bool enableDebugLogging = true;
  static const bool enableOfflineMode = true;
  static const bool enableSMSFallback = false;
  static const bool enableMockMode = true; // Enabled to disconnect real backend
  
  // Get full API URL
  static String getApiUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Environment detection
  static bool get isProduction => !baseUrl.contains('localhost');
  static bool get isDevelopment => baseUrl.contains('localhost');
  
  // Feature flags
  static bool get enableAnalytics => isProduction;
  static bool get enableGeospatialQueries => true;
  static bool get enableQualityMetrics => true;
}