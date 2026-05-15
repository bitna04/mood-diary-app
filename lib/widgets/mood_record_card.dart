import 'package:flutter/material.dart';
import '../models/mood_record.dart';

/// Widget to display a single mood record in a card format
/// Shows mood icon, note, date and delete button
class MoodRecordCard extends StatelessWidget {
  final MoodRecord record;
  final VoidCallback onDelete;

  const MoodRecordCard({
    super.key,
    required this.record,
    required this.onDelete,
  });

  /// Get the appropriate icon for the mood ID
  IconData _getMoodIcon(String moodId) {
    switch (moodId) {
      case 'excited':
        return Icons.sentiment_very_satisfied;
      case 'happy':
        return Icons.sentiment_satisfied;
      case 'love':
        return Icons.favorite;
      case 'calm':
        return Icons.self_improvement;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'crying':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.flash_on;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.pink.shade100,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with emoji and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mood icon in a rounded container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getMoodIcon(record.emoji),
                      size: 32,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ),
                // Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      record.getFormattedDate(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${record.date.hour}:${record.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Note text
            if (record.note.isNotEmpty)
              Text(
                record.note,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            // Delete button
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pink.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
