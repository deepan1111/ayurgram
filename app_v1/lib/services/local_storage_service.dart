import 'package:hive_flutter/hive_flutter.dart';
import '../models/collection_event.dart';
import 'web_storage_service.dart';

class LocalStorageService {
  static const String _collectionEventsBox = 'collection_events';
  static const String _settingsBox = 'settings';
  
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  
  LocalStorageService._();

  late Box<CollectionEvent> _collectionEventsBox_;
  late Box _settingsBox_;
  final WebStorageService _webStorage = WebStorageService.instance;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters (will be available after code generation)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CollectionEventAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(GPSLocationAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(QualityMetricsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SyncStatusAdapter());
    }

    // Open boxes with error handling
    try {
      _collectionEventsBox_ = await Hive.openBox<CollectionEvent>(_collectionEventsBox);
      _settingsBox_ = await Hive.openBox(_settingsBox);
      
      // Force a write to ensure persistence works
      await _testPersistence();
      
      // Restore from backup if Hive is empty but backup exists
      await _restoreFromBackupIfNeeded();
    } catch (e) {
      print('Error opening Hive boxes: $e');
      // Fallback: try to delete and recreate boxes
      try {
        await Hive.deleteBoxFromDisk(_collectionEventsBox);
        await Hive.deleteBoxFromDisk(_settingsBox);
        _collectionEventsBox_ = await Hive.openBox<CollectionEvent>(_collectionEventsBox);
        _settingsBox_ = await Hive.openBox(_settingsBox);
      } catch (e2) {
        print('Error recreating Hive boxes: $e2');
        rethrow;
      }
    }
  }

  Future<void> _testPersistence() async {
    // Test if data persists by writing and reading a test value
    const testKey = '_persistence_test';
    await _settingsBox_.put(testKey, DateTime.now().millisecondsSinceEpoch);
    final testValue = _settingsBox_.get(testKey);
    if (testValue == null) {
      throw Exception('Hive persistence test failed');
    }
  }

  Future<void> _restoreFromBackupIfNeeded() async {
    try {
      // Check if Hive is empty but backup exists
      if (_collectionEventsBox_.isEmpty && await _webStorage.hasBackupData()) {
        print('Hive is empty but backup exists. Restoring from backup...');
        final backupEvents = await _webStorage.loadCollectionEventsBackup();
        
        for (final event in backupEvents) {
          await _collectionEventsBox_.put(event.eventId, event);
        }
        
        print('Restored ${backupEvents.length} events from backup');
      }
    } catch (e) {
      print('Error restoring from backup: $e');
    }
  }

  // Collection Events Operations
  Future<void> saveCollectionEvent(CollectionEvent event) async {
    await _collectionEventsBox_.put(event.eventId, event);
    
    // Create backup in SharedPreferences
    await _createBackup();
  }

  Future<CollectionEvent?> getCollectionEvent(String eventId) async {
    return _collectionEventsBox_.get(eventId);
  }

  Future<List<CollectionEvent>> getAllCollectionEvents() async {
    return _collectionEventsBox_.values.toList();
  }

  Future<List<CollectionEvent>> getCollectionEventsByCollector(String collectorId) async {
    return _collectionEventsBox_.values
        .where((event) => event.collectorId == collectorId)
        .toList();
  }

  Future<List<CollectionEvent>> getPendingSyncEvents() async {
    return _collectionEventsBox_.values
        .where((event) => event.syncStatus == SyncStatus.pending || 
                         event.syncStatus == SyncStatus.failed)
        .toList();
  }

  Future<List<CollectionEvent>> getSMSQueuedEvents() async {
    return _collectionEventsBox_.values
        .where((event) => event.syncStatus == SyncStatus.smsQueued)
        .toList();
  }

  Future<void> updateCollectionEventSyncStatus(String eventId, SyncStatus status) async {
    final event = _collectionEventsBox_.get(eventId);
    if (event != null) {
      final updatedEvent = event.copyWith(
        syncStatus: status,
        lastSyncAttempt: DateTime.now(),
      );
      await _collectionEventsBox_.put(eventId, updatedEvent);
    }
  }

  Future<void> deleteCollectionEvent(String eventId) async {
    await _collectionEventsBox_.delete(eventId);
  }

  Future<void> clearAllCollectionEvents() async {
    await _collectionEventsBox_.clear();
  }

  // Settings Operations
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox_.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox_.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox_.delete(key);
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getCollectionStatistics(String collectorId) async {
    final events = await getCollectionEventsByCollector(collectorId);
    
    if (events.isEmpty) {
      return {
        'totalEvents': 0,
        'totalQuantity': 0.0,
        'syncedEvents': 0,
        'pendingEvents': 0,
        'failedEvents': 0,
        'speciesCount': 0,
        'lastCollection': null,
      };
    }

    final syncedEvents = events.where((e) => e.syncStatus == SyncStatus.synced).length;
    final pendingEvents = events.where((e) => e.syncStatus == SyncStatus.pending).length;
    final failedEvents = events.where((e) => e.syncStatus == SyncStatus.failed).length;
    
    final totalQuantity = events.fold<double>(0.0, (sum, event) => sum + event.quantity);
    final uniqueSpecies = events.map((e) => e.species).toSet().length;
    
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final lastCollection = events.first.timestamp;

    return {
      'totalEvents': events.length,
      'totalQuantity': totalQuantity,
      'syncedEvents': syncedEvents,
      'pendingEvents': pendingEvents,
      'failedEvents': failedEvents,
      'speciesCount': uniqueSpecies,
      'lastCollection': lastCollection,
    };
  }

  // Backup and Restore
  Future<List<Map<String, dynamic>>> exportCollectionEvents() async {
    final events = await getAllCollectionEvents();
    return events.map((event) => event.toJson()).toList();
  }

  Future<void> importCollectionEvents(List<Map<String, dynamic>> eventsData) async {
    for (final eventData in eventsData) {
      final event = CollectionEvent.fromJson(eventData);
      await saveCollectionEvent(event);
    }
  }

  // Cleanup old events (optional)
  Future<void> cleanupOldSyncedEvents({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final events = await getAllCollectionEvents();
    
    for (final event in events) {
      if (event.syncStatus == SyncStatus.synced && 
          event.timestamp.isBefore(cutoffDate)) {
        await deleteCollectionEvent(event.eventId);
      }
    }
  }

  Future<void> _createBackup() async {
    try {
      final allEvents = await getAllCollectionEvents();
      await _webStorage.saveCollectionEventsBackup(allEvents);
    } catch (e) {
      print('Error creating backup: $e');
    }
  }

  Future<void> close() async {
    await _collectionEventsBox_.close();
    await _settingsBox_.close();
  }
}
