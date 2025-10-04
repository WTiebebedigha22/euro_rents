import 'package:shared_preferences/shared_preferences.dart';

class OnboardingViewModel {
  static const String _seenKey = "hasSeenOnboarding";

  Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }
}
