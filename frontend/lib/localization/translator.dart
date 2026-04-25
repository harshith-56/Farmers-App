import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'app_strings.dart';

String t(BuildContext context, String key) {
  final lang = context.read<LanguageProvider>().language;
  return AppStrings.data[lang]?[key] ??
      AppStrings.data["en"]![key] ??
      key;
}
