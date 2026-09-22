import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/favourites/data/datasources/favourite_local_data_source.dart';
import 'package:property_listing/features/favourites/data/repositories/favourite_repository_impl.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('favourite IDs persist across repository instances', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final PreferencesService service = SharedPreferencesService(preferences);
    final FavouriteRepository repository = FavouriteRepositoryImpl(
      SharedPreferencesFavouriteLocalDataSource(service),
    );

    await repository.addFavourite('P002');
    await repository.addFavourite('P001');

    final FavouriteRepository restored = FavouriteRepositoryImpl(
      SharedPreferencesFavouriteLocalDataSource(service),
    );
    expect(await restored.getFavouriteIds(), <String>{'P001', 'P002'});

    await restored.removeFavourite('P001');
    expect(await repository.getFavouriteIds(), <String>{'P002'});
  });
}
