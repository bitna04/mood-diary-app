import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a single mood record entry
/// Contains the mood ID, note, and timestamp
class MoodRecord {
  final String id;
  final String emoji; // Now stores mood ID (e.g., 'happy', 'sad')
  final String note;
  final DateTime date;

  MoodRecord({
    this.id = '',
    required this.emoji,
    required this.note,
    required this.date,
  });

  MoodRecord copyWith({
    String? id,
    String? emoji,
    String? note,
    DateTime? date,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  /// Convert MoodRecord to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  /// Create MoodRecord from JSON data
  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      emoji: json['emoji'] as String,
      note: json['note'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Get formatted date string (e.g., "May 15, 2026")
  String getFormattedDate() {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Convert MoodRecord to Firestore document format
  Map<String, dynamic> toFirestoreMap() {
    return {
      'emoji': emoji,
      'note': note,
      'date': Timestamp.fromDate(date),
    };
  }

  /// Create MoodRecord from Firestore document snapshot
  factory MoodRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MoodRecord(
      id: doc.id,
      emoji: data['emoji'] as String,
      note: data['note'] as String,
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
