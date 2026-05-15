import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('[Google Sign-In] Starting Google Sign-In flow');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('[Google Sign-In] User cancelled the sign-in flow');
        return null;
      }

      developer.log('[Google Sign-In] User signed in: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      developer.log('[Google Sign-In] Got authentication tokens');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        developer.log('[Google Sign-In] ERROR: Missing authentication tokens',
          name: 'AuthService',
          level: 2000);
        throw Exception('Missing Google authentication tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );

      developer.log('[Google Sign-In] Creating Firebase credential');
      final result = await _auth.signInWithCredential(credential);
      developer.log('[Google Sign-In] Firebase authentication successful: ${result.user?.email}');

      return result;
    } catch (e) {
      developer.log('[Google Sign-In] Error: $e',
        name: 'AuthService',
        error: e,
        level: 2000);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      developer.log('[Google Sign-In] Starting sign out');
      await _googleSignIn.signOut();
      await _auth.signOut();
      developer.log('[Google Sign-In] Sign out successful');
    } catch (e) {
      developer.log('[Google Sign-In] Sign out error: $e',
        name: 'AuthService',
        error: e,
        level: 2000);
      rethrow;
    }
  }

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  static User? get currentUser => _auth.currentUser;
}
