# Mood Diary App Structure

## Project Overview
A simple Flutter app for tracking daily moods with emoji selection and note-taking features.

## File Structure

### lib/main.dart
- **MoodDiaryApp**: Main app widget that sets up the theme (warm pink colors)
- **HomeScreen**: The main screen where users:
  - Select a mood from 8 emoji options
  - Write an optional note
  - View and manage previous mood entries

### lib/models/mood_record.dart
- **MoodRecord**: Data model representing a single mood entry
  - `emoji`: Selected mood emoji
  - `note`: User's note text
  - `date`: Timestamp of the entry
  - Methods: `toJson()`, `fromJson()`, `getFormattedDate()`

### lib/services/storage_service.dart
- **StorageService**: Handles all local storage operations using SharedPreferences
  - `init()`: Initialize the service (called in main)
  - `saveMoodRecord()`: Save a new mood entry
  - `getAllRecords()`: Fetch all saved entries (sorted by date)
  - `deleteRecord()`: Remove a specific entry
  - `clearAllRecords()`: Delete all entries

### lib/widgets/mood_record_card.dart
- **MoodRecordCard**: Displays a single mood record in an attractive card format
  - Shows mood emoji, note, date, and time
  - Includes delete button for easy removal

## Key Features

1. **Mood Selection**: Grid of 8 emoji buttons (😄 😊 😍 😌 😐 😔 😢 😤)
2. **Note Taking**: Optional text area for thoughts
3. **Storage**: All records saved locally using SharedPreferences
4. **Display**: Scrollable list of previous entries sorted by newest first
5. **Delete**: Remove individual entries with a single tap

## Design Elements

- **Color Scheme**: Warm pink theme (Colors.pink family)
- **UI Components**:
  - Rounded cards (borderRadius: 12-16)
  - Gradient backgrounds
  - Smooth shadows and elevation
  - Responsive layout

## How to Run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device-id>
```

## Dependencies

- **flutter**: Core framework
- **shared_preferences**: Local data persistence
- **intl**: Date/time formatting utilities

## Beginner Tips

- The `setState()` method updates the UI when data changes
- `async/await` handles asynchronous storage operations
- The model class separates data logic from UI logic
- Services encapsulate storage operations for reusability
