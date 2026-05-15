import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_record.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatelessWidget {
  final List<MoodRecord> records;

  const StatsScreen({super.key, required this.records});

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

  String _getMoodLabel(String moodId) {
    switch (moodId) {
      case 'excited':
        return 'Excited';
      case 'happy':
        return 'Happy';
      case 'love':
        return 'Love';
      case 'calm':
        return 'Calm';
      case 'neutral':
        return 'Neutral';
      case 'sad':
        return 'Sad';
      case 'crying':
        return 'Crying';
      case 'angry':
        return 'Angry';
      default:
        return 'Unknown';
    }
  }

  Color _getMoodColor(String moodId) {
    switch (moodId) {
      case 'excited':
        return Colors.amber.shade500;
      case 'happy':
        return Colors.orange.shade500;
      case 'love':
        return Colors.red.shade500;
      case 'calm':
        return Colors.blue.shade500;
      case 'neutral':
        return Colors.grey.shade500;
      case 'sad':
        return Colors.indigo.shade500;
      case 'crying':
        return Colors.purple.shade500;
      case 'angry':
        return Colors.deepOrange.shade500;
      default:
        return Colors.pink.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 64,
                    color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No mood data yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? const Color(0xFFBDBDBD)
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging your moods to see statistics',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color(0xFF9E9E9E)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Entries',
                      value: StatsService.totalEntries(records).toString(),
                      icon: Icons.summarize,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TopMoodCard(
                      moodId: StatsService.topMood(records),
                      getMoodIcon: _getMoodIcon,
                      getMoodLabel: _getMoodLabel,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Activity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WeeklyChart(
                    records: records,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mood Distribution
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MoodDistributionChart(
                    records: records,
                    isDarkMode: isDarkMode,
                    getMoodColor: _getMoodColor,
                    getMoodLabel: _getMoodLabel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDarkMode;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                : [Colors.pink.shade50, Colors.pink.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.pink.shade400,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? const Color(0xFF9E9E9E)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMoodCard extends StatelessWidget {
  final String? moodId;
  final IconData Function(String) getMoodIcon;
  final String Function(String) getMoodLabel;
  final bool isDarkMode;

  const _TopMoodCard({
    required this.moodId,
    required this.getMoodIcon,
    required this.getMoodLabel,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                : [Colors.pink.shade50, Colors.pink.shade100],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.pink.shade400,
              size: 28,
            ),
            const SizedBox(height: 12),
            if (moodId != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    getMoodIcon(moodId!),
                    size: 32,
                    color: Colors.pink.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getMoodLabel(moodId!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              )
            else
              Text(
                '-',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Top Mood',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? const Color(0xFF9E9E9E)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<MoodRecord> records;
  final bool isDarkMode;

  const _WeeklyChart({
    required this.records,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final data = StatsService.last7DaysCounts(records);
    final maxY = data.isEmpty ? 1.0 : data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble() + 1;

    final List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].count.toDouble(),
                  color: Colors.pink.shade400,
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dayLabels.length) {
                    return Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? const Color(0xFF9E9E9E)
                            : Colors.grey.shade600,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? const Color(0xFF9E9E9E)
                          : Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode
                    ? const Color(0xFF444444)
                    : Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
        ),
      ),
    );
  }
}

class _MoodDistributionChart extends StatelessWidget {
  final List<MoodRecord> records;
  final bool isDarkMode;
  final Color Function(String) getMoodColor;
  final String Function(String) getMoodLabel;

  const _MoodDistributionChart({
    required this.records,
    required this.isDarkMode,
    required this.getMoodColor,
    required this.getMoodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final counts = StatsService.moodCounts(records);
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = records.length;

    return Column(
      children: List.generate(
        sortedEntries.length,
        (index) {
          final entry = sortedEntries[index];
          final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0';
          final barFlex = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getMoodLabel(entry.key),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${entry.value} ($percentage%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: getMoodColor(entry.key),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: barFlex / (sortedEntries.first.value),
                    minHeight: 24,
                    backgroundColor:
                        isDarkMode ? const Color(0xFF444444) : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(getMoodColor(entry.key)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
