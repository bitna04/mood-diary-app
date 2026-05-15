import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/mood_record.dart';
import '../widgets/mood_record_card.dart';

class CalendarScreen extends StatefulWidget {
  final List<MoodRecord> records;

  const CalendarScreen({super.key, required this.records});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<MoodRecord>> _eventMap;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _buildEventMap();
  }

  void _buildEventMap() {
    _eventMap = {};
    for (final record in widget.records) {
      final day = DateTime(record.date.year, record.date.month, record.date.day);
      _eventMap.putIfAbsent(day, () => []).add(record);
    }
  }

  @override
  Widget build(BuildContext context) {
    _buildEventMap();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final selectedDayRecords =
        _eventMap[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Calendar widget
          TableCalendar<MoodRecord>(
            firstDay: DateTime.now().subtract(const Duration(days: 730)),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _eventMap[DateTime(day.year, day.month, day.day)] ?? [];
            },
            calendarStyle: CalendarStyle(
              // Selected day styling
              selectedDecoration: BoxDecoration(
                color: isDarkMode ? Colors.pink.shade400 : Colors.pink.shade300,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              // Today styling
              todayDecoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF3A1A2A) : Colors.pink.shade100,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: isDarkMode ? Colors.pink.shade300 : Colors.pink.shade700,
                fontWeight: FontWeight.bold,
              ),
              // Default day styling
              defaultTextStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color: isDarkMode ? Colors.pink.shade300 : Colors.pink.shade400,
              ),
              outsideTextStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
              // Marker styling
              markerDecoration: BoxDecoration(
                color: isDarkMode ? Colors.pink.shade300 : Colors.pink.shade400,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.pink.shade700,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDarkMode ? Colors.white : Colors.pink.shade400,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.white : Colors.pink.shade400,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              weekdayStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Selected day section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM d, y').format(_selectedDay),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Records list for selected day
          if (selectedDayRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No entries for this day',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode
                          ? const Color(0xFFBDBDBD)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayRecords.length,
              itemBuilder: (context, index) {
                final record = selectedDayRecords[index];
                return MoodRecordCard(
                  record: record,
                  onDelete: () {},
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
