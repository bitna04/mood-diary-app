import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_record.dart';

/// Service class to handle local storage using SharedPreferences
/// Manages saving and loading mood records from device storage
class StorageService {
  static const String _storageKey = 'mood_records';
  static late SharedPreferences _prefs;

  /// Initialize the storage service
  /// Must be called before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a mood record to local storage
  static Future<bool> saveMoodRecord(MoodRecord record) async {
    try {
      final records = await getAllRecords();
      records.add(record);

      // Convert all records to JSON and save
      final jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
      return await _prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error saving mood record: $e');
      return false;
    }
  }

  /// Get all saved mood records, sorted by date (newest first)
  static Future<List<MoodRecord>> getAllRecords() async {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      final records = jsonList
          .map((json) => MoodRecord.fromJson(jsonDecode(json)))
          .toList();

      // Sort by date, newest first
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    } catch (e) {
      print('Error loading mood records: $e');
      return [];
    }
  }

  /// Delete a specific mood record
  static Future<bool> deleteRecord(MoodRecord record) async {
    try {
      final records = await getAllRecords();
      records.removeWhere((r) =>
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day &&
          r.emoji == record.emoji);

      final jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
      return await _prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error deleting mood record: $e');
      return false;
    }
  }

  /// Clear all saved mood records
  static Future<bool> clearAllRecords() async {
    try {
      return await _prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing records: $e');
      return false;
    }
  }
}
