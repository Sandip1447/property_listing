import 'package:injectable/injectable.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';

abstract interface class FavouriteLocalDataSource {
  Set<String> getFavouriteIds();

  Future<void> saveFavouriteIds(Set<String> ids);
}

@LazySingleton(as: FavouriteLocalDataSource)
final class SharedPreferencesFavouriteLocalDataSource
    implements FavouriteLocalDataSource {
  const SharedPreferencesFavouriteLocalDataSource(this._preferences);

  final PreferencesService _preferences;

  @override
  Set<String> getFavouriteIds() {
    try {
      return Set<String>.unmodifiable(
        _preferences.getStringList(StorageKeys.favouritePropertyIds) ??
            const <String>[],
      );
    } on Object catch (error) {
      throw StorageException('Unable to read favourites: $error');
    }
  }

  @override
  Future<void> saveFavouriteIds(Set<String> ids) async {
    try {
      final List<String> sortedIds = ids.toList()..sort();
      await _preferences.setStringList(
        StorageKeys.favouritePropertyIds,
        sortedIds,
      );
    } on Object catch (error) {
      throw StorageException('Unable to save favourites: $error');
    }
  }
}
