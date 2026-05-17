import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static late SharedPreferences _prefs;
  static const _key = 'onboarding_complete';

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(_key) ?? false;
  }

  static Future<void> setComplete() async {
    await _prefs.setBool(_key, true);
  }

  static Future<void> reset() async {
    await _prefs.remove(_key);
  }
}
