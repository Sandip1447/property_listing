import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesService {
  Future<void> setString(String key, String value);

  String? getString(String key);

  Future<void> setStringList(String key, List<String> value);

  List<String>? getStringList(String key);

  Future<void> remove(String key);
}

@LazySingleton(as: PreferencesService)
final class SharedPreferencesService implements PreferencesService {
  SharedPreferencesService(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  List<String>? getStringList(String key) => _preferences.getStringList(key);

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }
}
