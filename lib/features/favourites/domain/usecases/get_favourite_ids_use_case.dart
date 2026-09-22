import 'package:injectable/injectable.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';

@lazySingleton
final class GetFavouriteIdsUseCase {
  const GetFavouriteIdsUseCase(this._repository);

  final FavouriteRepository _repository;

  Future<Set<String>> call() => _repository.getFavouriteIds();
}
