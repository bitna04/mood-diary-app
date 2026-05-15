import '../models/mood_record.dart';

class StatsService {
  static int totalEntries(List<MoodRecord> records) => records.length;

  static String? topMood(List<MoodRecord> records) {
    if (records.isEmpty) return null;
    final counts = moodCounts(records);
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static Map<String, int> moodCounts(List<MoodRecord> records) {
    final Map<String, int> counts = {};
    for (final record in records) {
      counts[record.emoji] = (counts[record.emoji] ?? 0) + 1;
    }
    return counts;
  }

  static List<({DateTime date, int count})> last7DaysCounts(
      List<MoodRecord> records) {
    final now = DateTime.now();
    final last7Days = <DateTime>[];

    for (int i = 6; i >= 0; i--) {
      last7Days.add(DateTime(now.year, now.month, now.day - i));
    }

    final result = <({DateTime date, int count})>[];
    for (final day in last7Days) {
      final count = records.where((r) {
        return r.date.year == day.year &&
            r.date.month == day.month &&
            r.date.day == day.day;
      }).length;
      result.add((date: day, count: count));
    }

    return result;
  }

  static Map<String, int> moodCountsForDay(List<MoodRecord> records, DateTime day) {
    final dayRecords = records.where((r) {
      return r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day;
    }).toList();
    return moodCounts(dayRecords);
  }
}
