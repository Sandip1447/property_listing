import 'package:injectable/injectable.dart';
import 'package:property_listing/features/favourites/data/datasources/favourite_local_data_source.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';

@LazySingleton(as: FavouriteRepository)
final class FavouriteRepositoryImpl implements FavouriteRepository {
  const FavouriteRepositoryImpl(this._localDataSource);

  final FavouriteLocalDataSource _localDataSource;

  @override
  Future<Set<String>> getFavouriteIds() async =>
      _localDataSource.getFavouriteIds();

  @override
  Future<void> addFavourite(String propertyId) async {
    final Set<String> ids = <String>{
      ..._localDataSource.getFavouriteIds(),
      propertyId,
    };
    await _localDataSource.saveFavouriteIds(ids);
  }

  @override
  Future<void> removeFavourite(String propertyId) async {
    final Set<String> ids = <String>{..._localDataSource.getFavouriteIds()}
      ..remove(propertyId);
    await _localDataSource.saveFavouriteIds(ids);
  }
}
