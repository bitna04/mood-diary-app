/// Model class representing a single mood record entry
/// Contains the mood ID, note, and timestamp
class MoodRecord {
  final String emoji; // Now stores mood ID (e.g., 'happy', 'sad')
  final String note;
  final DateTime date;

  MoodRecord({
    required this.emoji,
    required this.note,
    required this.date,
  });

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
}
