import 'package:flutter/material.dart';
import '../models/mood_record.dart';
import '../models/ai_reflection.dart';
import '../services/ai_service.dart';

class AiReflectionSheet extends StatefulWidget {
  final MoodRecord record;

  const AiReflectionSheet({
    super.key,
    required this.record,
  });

  @override
  State<AiReflectionSheet> createState() => _AiReflectionSheetState();
}

class _AiReflectionSheetState extends State<AiReflectionSheet> {
  late Future<AiReflection> _reflectionFuture;

  @override
  void initState() {
    super.initState();
    _reflectionFuture =
        AiService.generateReflection(widget.record.emoji, widget.record.note);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accentPink =
        isDarkMode ? Colors.pink.shade400 : Colors.pink.shade300;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Icon(Icons.auto_awesome, color: accentPink, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'AI Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: FutureBuilder<AiReflection>(
                future: _reflectionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: accentPink),
                          const SizedBox(height: 16),
                          Text(
                            'Reflecting on your mood...',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade400, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to generate reflection',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final reflection = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [
                                    const Color(0xFF2A2A2A),
                                    const Color(0xFF1F1F1F)
                                  ]
                                : [Colors.pink.shade50, Colors.pink.shade100],
                          ),
                        ),
                        child: Text(
                          reflection.reflection,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: isDarkMode
                                ? const Color(0xFFBDBDBD)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Emotions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: reflection.keywords
                            .map(
                              (keyword) => Chip(
                                label: Text(keyword),
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.pink.shade100,
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode
                                      ? Colors.pink.shade300
                                      : Colors.pink.shade700,
                                ),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: accentPink, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Self-care',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: accentPink,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Text(
                          reflection.suggestion,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDarkMode
                                ? const Color(0xFFBDBDBD)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: accentPink,
                ),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
