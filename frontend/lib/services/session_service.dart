import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _isLoggedInKey = "is_logged_in";
  static const String _phoneKey = "user_phone";
  static const String _nameKey = "user_name";
  static const String _languageKey = "user_language";

  static Future<void> saveUser({
    required String phone,
    required String name,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_languageKey, language);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "phone": prefs.getString(_phoneKey) ?? "",
      "name": prefs.getString(_nameKey) ?? "",
      "language": prefs.getString(_languageKey) ?? "en",
    };
  }

  static Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<void> updateLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_languageKey);
  }
}
