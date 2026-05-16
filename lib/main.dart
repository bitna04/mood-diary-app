import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'models/mood_record.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'services/security_service.dart';
import 'services/onboarding_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'themes/app_theme.dart';
import 'widgets/mood_record_card.dart';
import 'widgets/ai_reflection_sheet.dart';
import 'screens/stats_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await StorageService.init();
  await ThemeService.init();
  await SecurityService.init();
  final onboardingComplete = await OnboardingService.init();
  runApp(MoodDiaryApp(onboardingComplete: onboardingComplete));
}

class MoodDiaryApp extends StatefulWidget {
  final bool onboardingComplete;

  const MoodDiaryApp({
    super.key,
    required this.onboardingComplete,
  });

  @override
  State<MoodDiaryApp> createState() => _MoodDiaryAppState();
}

class _MoodDiaryAppState extends State<MoodDiaryApp> {
  late ThemeMode _themeMode;
  late bool _onboardingComplete;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _themeMode = ThemeService.getSavedThemeMode();
    _onboardingComplete = widget.onboardingComplete;
    _isLocked = SecurityService.isPinEnabled();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    ThemeService.saveThemeMode(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Diary',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: AuthService.authStateChanges(),
        builder: (context, snapshot) {
          if (!_onboardingComplete) {
            return OnboardingScreen(
              onComplete: () async {
                await OnboardingService.setComplete();
                setState(() => _onboardingComplete = true);
              },
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.pink.shade300,
                ),
              ),
            );
          }

          if (snapshot.data == null) {
            return const AuthScreen();
          }

          if (_isLocked) {
            return LockScreen(
              mode: LockScreenMode.unlock,
              onSuccess: () => setState(() => _isLocked = false),
            );
          }

          return HomeScreen(
            onThemeToggle: _toggleTheme,
            user: snapshot.data!,
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final User user;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _pinEnabled = false;

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

  late StreamSubscription<List<MoodRecord>> _recordsSubscription;

  @override
  void initState() {
    super.initState();
    _pinEnabled = SecurityService.isPinEnabled();
    _recordsSubscription = FirestoreService.recordsStream(widget.user.uid)
        .listen((records) {
      if (mounted) {
        setState(() => _records = records);
      }
    });
    _runMigrationIfNeeded();
  }

  Future<void> _runMigrationIfNeeded() async {
    final local = await StorageService.getAllRecords();
    if (local.isNotEmpty) {
      await FirestoreService.migrateLocalRecords(widget.user.uid, local);
    }
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

    try {
      await FirestoreService.addRecord(widget.user.uid, record);

      // Clear the form
      setState(() {
        _selectedMood = null;
        _noteController.clear();
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood saved!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e')),
        );
      }
    }
  }

  /// Delete a mood record
  Future<void> _deleteRecord(MoodRecord record) async {
    try {
      await FirestoreService.deleteRecord(widget.user.uid, record.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting mood: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Diary'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_pinEnabled ? Icons.lock : Icons.lock_open),
            onPressed: _showLockSettings,
            tooltip: 'Lock Settings',
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'signout') {
                await AuthService.signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.pink.shade400),
                    const SizedBox(width: 8),
                    const Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeBody(
            noteController: _noteController,
            selectedMood: _selectedMood,
            moods: _moods,
            records: _records,
            isDarkMode: isDarkMode,
            onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            onSaveMood: _saveMood,
            onDeleteRecord: _deleteRecord,
            onReflect: _showReflectionSheet,
          ),
          StatsScreen(records: _records),
          CalendarScreen(records: _records, onReflect: _showReflectionSheet),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _recordsSubscription.cancel();
    super.dispose();
  }

  void _showReflectionSheet(MoodRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiReflectionSheet(record: record),
    );
  }

  void _showLockSettings() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LockSettingsSheet(
        pinEnabled: _pinEnabled,
        onPinToggled: () {
          Navigator.pop(ctx);
          if (!_pinEnabled) {
            // Navigate to setup PIN
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LockScreen(
                  mode: LockScreenMode.setup,
                  onSuccess: () {
                    Navigator.pop(context);
                    setState(() => _pinEnabled = true);
                  },
                  onCancel: () => Navigator.pop(context),
                ),
              ),
            );
          } else {
            // Verify current PIN then remove
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LockScreen(
                  mode: LockScreenMode.unlock,
                  onSuccess: () {
                    SecurityService.removePin().then((_) {
                      Navigator.pop(context);
                      setState(() => _pinEnabled = false);
                    });
                  },
                  onCancel: () => Navigator.pop(context),
                ),
              ),
            );
          }
        },
        onChangePin: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LockScreen(
                mode: LockScreenMode.change,
                onSuccess: () => Navigator.pop(context),
                onCancel: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final TextEditingController noteController;
  final String? selectedMood;
  final List<Map<String, dynamic>> moods;
  final List<MoodRecord> records;
  final bool isDarkMode;
  final Function(String) onMoodSelected;
  final VoidCallback onSaveMood;
  final Function(MoodRecord) onDeleteRecord;
  final Function(MoodRecord) onReflect;

  const _HomeBody({
    required this.noteController,
    required this.selectedMood,
    required this.moods,
    required this.records,
    required this.isDarkMode,
    required this.onMoodSelected,
    required this.onSaveMood,
    required this.onDeleteRecord,
    required this.onReflect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
            // Mood Selection Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                      : [Colors.pink.shade100, Colors.pink.shade200],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
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
                    itemCount: moods.length,
                    itemBuilder: (context, index) {
                      final mood = moods[index];
                      final moodId = mood['id'] as String;
                      final isSelected = selectedMood == moodId;

                      return GestureDetector(
                        onTap: () => onMoodSelected(moodId),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.pink.shade300
                                : (isDarkMode
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.pink.shade400
                                    : (isDarkMode
                                        ? Colors.black26
                                        : Colors.grey.shade300),
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
                  Text(
                    'Add a note (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write what\'s on your mind...',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? const Color(0xFF9E9E9E)
                            : Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.pink.shade600
                              : Colors.pink.shade200,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.pink.shade400,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : Colors.pink.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSaveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.pink.shade400
                            : Colors.pink.shade300,
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
                    color: isDarkMode
                        ? const Color(0xFFE0E0E0)
                        : Colors.grey.shade800,
                  ),
                ),
              ),
            ),

            // Scrollable list of mood records
            records.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No mood entries yet. Start by recording your mood!',
                      style: TextStyle(
                        color: isDarkMode
                            ? const Color(0xFF9E9E9E)
                            : Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return MoodRecordCard(
                        record: record,
                        onDelete: () => onDeleteRecord(record),
                        onReflect: () => onReflect(record),
                      );
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
  }

class _LockSettingsSheet extends StatefulWidget {
  final bool pinEnabled;
  final VoidCallback onPinToggled;
  final VoidCallback onChangePin;

  const _LockSettingsSheet({
    required this.pinEnabled,
    required this.onPinToggled,
    required this.onChangePin,
  });

  @override
  State<_LockSettingsSheet> createState() => _LockSettingsSheetState();
}

class _LockSettingsSheetState extends State<_LockSettingsSheet> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _biometricEnabled = SecurityService.isBiometricEnabled();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await SecurityService.isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Lock Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // PIN toggle
          SwitchListTile(
            title: Text(
              'Enable PIN Lock',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              widget.pinEnabled ? 'PIN is enabled' : 'No PIN set',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            value: widget.pinEnabled,
            onChanged: (_) => widget.onPinToggled(),
          ),
          // Change PIN
          if (widget.pinEnabled)
            ListTile(
              title: Text(
                'Change PIN',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              onTap: widget.onChangePin,
            ),
          // Biometric toggle
          if (widget.pinEnabled && _biometricAvailable)
            SwitchListTile(
              title: Text(
                'Face ID / Touch ID',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                _biometricEnabled ? 'Biometric enabled' : 'Use PIN only',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
                SecurityService.setBiometricEnabled(value);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
