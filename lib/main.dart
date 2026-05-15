import 'package:flutter/material.dart';
import 'models/mood_record.dart';
import 'services/storage_service.dart';
import 'widgets/mood_record_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MoodDiaryApp());
}

class MoodDiaryApp extends StatelessWidget {
  const MoodDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Diary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink.shade300,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller for the note text field
  final TextEditingController _noteController = TextEditingController();

  // Currently selected mood emoji
  String? _selectedMood;

  // Mood configuration with icons and labels
  static const List<Map<String, dynamic>> _moods = [
    {'id': 'excited', 'icon': Icons.sentiment_very_satisfied, 'label': 'Excited'},
    {'id': 'happy', 'icon': Icons.sentiment_satisfied, 'label': 'Happy'},
    {'id': 'love', 'icon': Icons.favorite, 'label': 'Love'},
    {'id': 'calm', 'icon': Icons.self_improvement, 'label': 'Calm'},
    {'id': 'neutral', 'icon': Icons.sentiment_neutral, 'label': 'Neutral'},
    {'id': 'sad', 'icon': Icons.sentiment_dissatisfied, 'label': 'Sad'},
    {'id': 'crying', 'icon': Icons.sentiment_very_dissatisfied, 'label': 'Crying'},
    {'id': 'angry', 'icon': Icons.flash_on, 'label': 'Angry'},
  ];

  // List of saved mood records
  List<MoodRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// Load all saved records from storage
  Future<void> _loadRecords() async {
    final records = await StorageService.getAllRecords();
    setState(() {
      _records = records;
    });
  }

  /// Save the current mood entry
  Future<void> _saveMood() async {
    // Validate that a mood is selected
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    // Create a new mood record
    final record = MoodRecord(
      emoji: _selectedMood!,
      note: _noteController.text.trim(),
      date: DateTime.now(),
    );

    // Save to storage
    final success = await StorageService.saveMoodRecord(record);

    if (success) {
      // Clear the form and refresh the list
      setState(() {
        _selectedMood = null;
        _noteController.clear();
      });
      await _loadRecords();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Delete a mood record
  Future<void> _deleteRecord(MoodRecord record) async {
    final success = await StorageService.deleteRecord(record);
    if (success) {
      await _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Diary'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Mood Selection Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.pink.shade100, Colors.pink.shade200],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid of mood icon buttons
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final moodId = mood['id'] as String;
                      final isSelected = _selectedMood == moodId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = moodId;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.pink.shade300
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.pink.shade400
                                    : Colors.grey.shade300,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mood['icon'] as IconData,
                                size: 32,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.pink.shade400,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.pink.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Note Input Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a note (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write what\'s on your mind...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.pink.shade200, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.pink.shade400, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.pink.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Mood',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Saved Records Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Previous Moods',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            // Scrollable list of mood records
            _records.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No mood entries yet. Start by recording your mood!',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return MoodRecordCard(
                        record: record,
                        onDelete: () => _deleteRecord(record),
                      );
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
