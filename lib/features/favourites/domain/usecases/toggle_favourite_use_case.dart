import 'package:injectable/injectable.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';

@lazySingleton
final class ToggleFavouriteUseCase {
  const ToggleFavouriteUseCase(this._repository);

  final FavouriteRepository _repository;

  Future<Set<String>> call(String propertyId) async {
    final Set<String> ids = await _repository.getFavouriteIds();
    if (ids.contains(propertyId)) {
      await _repository.removeFavourite(propertyId);
    } else {
      await _repository.addFavourite(propertyId);
    }
    return _repository.getFavouriteIds();
  }
}
