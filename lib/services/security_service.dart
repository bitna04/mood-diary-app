import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecurityService {
  static const String _pinKey = 'pin_hash';
  static const String _biometricKey = 'biometric_enabled';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _salt = 'MoodDiary_AppLock_Salt_v1';

  static late SharedPreferences _prefs;
  static final _localAuth = LocalAuthentication();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool isPinEnabled() {
    return _prefs.getBool(_pinEnabledKey) ?? false;
  }

  static String _hashPin(String pin) {
    return sha256.convert(utf8.encode('$_salt:$pin')).toString();
  }

  static Future<bool> savePin(String pin) async {
    try {
      final hash = _hashPin(pin);
      await _prefs.setString(_pinKey, hash);
      return await _prefs.setBool(_pinEnabledKey, true);
    } catch (e) {
      print('Error saving PIN: $e');
      return false;
    }
  }

  static bool verifyPin(String pin) {
    try {
      final stored = _prefs.getString(_pinKey);
      if (stored == null) return false;
      return stored == _hashPin(pin);
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  static Future<void> removePin() async {
    try {
      await _prefs.remove(_pinKey);
      await _prefs.setBool(_pinEnabledKey, false);
      await _prefs.setBool(_biometricKey, false);
    } catch (e) {
      print('Error removing PIN: $e');
    }
  }

  static bool isBiometricEnabled() {
    return _prefs.getBool(_biometricKey) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_biometricKey, enabled);
    } catch (e) {
      print('Error setting biometric: $e');
    }
  }

  static Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isSupported && canCheckBiometrics;
    } catch (e) {
      print('Error checking biometric: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock Mood Diary',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
