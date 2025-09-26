import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/collection_event.dart';

class WebStorageService {
  static WebStorageService? _instance;
  static WebStorageService get instance => _instance ??= WebStorageService._();
  
  WebStorageService._();

  static const String _collectionEventsKey = 'collection_events';
  static const String _statisticsKey = 'statistics';
  static const String _settingsKey = 'app_settings';

  // Save collection events to SharedPreferences as backup
  Future<void> saveCollectionEventsBackup(List<CollectionEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = events.map((e) => e.toJson()).toList();
      await prefs.setString(_collectionEventsKey, jsonEncode(eventsJson));
      print('Saved ${events.length} events to SharedPreferences backup');
    } catch (e) {
      print('Error saving events backup: $e');
    }
  }

  // Load collection events from SharedPreferences backup
  Future<List<CollectionEvent>> loadCollectionEventsBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsString = prefs.getString(_collectionEventsKey);
      
      if (eventsString != null) {
        final List<dynamic> eventsJson = jsonDecode(eventsString);
        final events = eventsJson.map((json) => CollectionEvent.fromJson(json)).toList();
        print('Loaded ${events.length} events from SharedPreferences backup');
        return events;
      }
    } catch (e) {
      print('Error loading events backup: $e');
    }
    return [];
  }

  // Save statistics backup
  Future<void> saveStatisticsBackup(Map<String, dynamic> statistics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statisticsKey, jsonEncode(statistics));
    } catch (e) {
      print('Error saving statistics backup: $e');
    }
  }

  // Load statistics backup
  Future<Map<String, dynamic>> loadStatisticsBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statisticsString = prefs.getString(_statisticsKey);
      
      if (statisticsString != null) {
        return Map<String, dynamic>.from(jsonDecode(statisticsString));
      }
    } catch (e) {
      print('Error loading statistics backup: $e');
    }
    return {};
  }

  // Save app settings
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = await _loadAllSettings();
      settings[key] = value;
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      print('Error saving setting: $e');
    }
  }

  // Get app setting
  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    try {
      final settings = await _loadAllSettings();
      return settings[key] as T? ?? defaultValue;
    } catch (e) {
      print('Error getting setting: $e');
      return defaultValue;
    }
  }

  // Load all settings
  Future<Map<String, dynamic>> _loadAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_settingsKey);
      
      if (settingsString != null) {
        return Map<String, dynamic>.from(jsonDecode(settingsString));
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return {};
  }

  // Clear all backup data
  Future<void> clearAllBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_collectionEventsKey);
      await prefs.remove(_statisticsKey);
      await prefs.remove(_settingsKey);
      print('Cleared all backup data');
    } catch (e) {
      print('Error clearing backups: $e');
    }
  }

  // Check if backup data exists
  Future<bool> hasBackupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_collectionEventsKey);
    } catch (e) {
      return false;
    }
  }
}
