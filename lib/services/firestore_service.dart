import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_record.dart';
import 'storage_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference _col(String uid) {
    return _firestore.collection('users').doc(uid).collection('mood_records');
  }

  static Stream<List<MoodRecord>> recordsStream(String uid) {
    return _col(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MoodRecord.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }

  static Future<MoodRecord> addRecord(String uid, MoodRecord record) async {
    final docRef = await _col(uid).add(record.toFirestoreMap());
    return record.copyWith(id: docRef.id);
  }

  static Future<void> deleteRecord(String uid, String recordId) {
    return _col(uid).doc(recordId).delete();
  }

  static Future<void> migrateLocalRecords(
    String uid,
    List<MoodRecord> localRecords,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final migrationKey = 'migrated_$uid';

    if (prefs.getBool(migrationKey) == true) {
      return;
    }

    final batch = _firestore.batch();
    for (final record in localRecords) {
      final docRef = _col(uid).doc();
      batch.set(docRef, record.toFirestoreMap());
    }

    await batch.commit();
    await StorageService.clearAllRecords();
    await prefs.setBool(migrationKey, true);
  }
}
