import 'package:flutter/material.dart';
import '../services/session_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = "en";

  String get language => _language;

  Future<void> loadLanguageFromSession() async {
    final user = await SessionService.getUser();
    _language = user["language"] ?? "en";
    notifyListeners();
  }

  Future<void> changeLanguage(String lang) async {
    _language = lang;
    await SessionService.updateLanguage(lang);
    notifyListeners();
  }
}
