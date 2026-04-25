import 'language_map.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  String t(String key) {
    return languageMap[languageCode]?[key]
        ?? languageMap["en"]![key]
        ?? key;
  }
}
