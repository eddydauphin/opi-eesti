import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';

/// Learner preferences, currently just the language they learn from.
class SettingsStore extends ChangeNotifier {
  SettingsStore({String? language}) : _language = language; // ignore: prefer_initializing_formals

  static const _langKey = 'learner_lang';

  String? _language;

  /// Null until the learner has picked a language on first launch.
  String? get language => _language;

  Strings get strings => Strings.of(_language ?? 'en');

  static Future<SettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_langKey);
    return SettingsStore(language: Strings.supported.contains(lang) ? lang : null);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }
}
