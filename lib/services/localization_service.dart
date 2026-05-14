import 'package:flutter/material.dart';
import '../l10n/app_en.dart';
import '../l10n/app_ar.dart';
import '../l10n/app_fr.dart';

class LocalizationService extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
  ];

  static const _strings = {
    'en': AppEn.strings,
    'ar': AppAr.strings,
    'fr': AppFr.strings,
  };

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  static String translate(String key, [String language = 'en']) {
    return _strings[language]?[key] ?? _strings['en']?[key] ?? key;
  }

  String tr(String key) {
    return _strings[_locale.languageCode]?[key] ??
        _strings['en']?[key] ??
        key;
  }
}
