import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemapedia/config/constants/app_languages.dart';

const _kLangKey = 'app_language_code';

/// Provider que expone la SharedPreferences (inicializado en main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Notifier que maneja el idioma activo y lo persiste
class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  LanguageNotifier(this._prefs) : super(_prefs.getString(_kLangKey) ?? 'es');

  void setLanguage(String langCode) {
    state = langCode;
    _prefs.setString(_kLangKey, langCode);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

/// Código TMDB derivado del idioma activo (ej. 'es-MX', 'en-US')
final tmdbLanguageProvider = Provider<String>((ref) {
  final langCode = ref.watch(languageProvider);
  return AppLanguages.getTmdbCode(langCode);
});
