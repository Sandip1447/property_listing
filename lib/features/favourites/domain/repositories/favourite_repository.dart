abstract interface class FavouriteRepository {
  Future<Set<String>> getFavouriteIds();

  Future<void> addFavourite(String propertyId);

  Future<void> removeFavourite(String propertyId);
}
