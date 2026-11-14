import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemapedia/presentation/providers/language/language_provider.dart';

const _kContentTypeKey = 'content_type';

/// 'movie' o 'tv'
class ContentTypeNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  ContentTypeNotifier(this._prefs)
      : super(_prefs.getString(_kContentTypeKey) ?? 'movie');

  void setContentType(String type) {
    state = type;
    _prefs.setString(_kContentTypeKey, type);
  }

  bool get isMovies => state == 'movie';
  bool get isSeries => state == 'tv';
}

final contentTypeProvider =
    StateNotifierProvider<ContentTypeNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ContentTypeNotifier(prefs);
});
