import 'package:equatable/equatable.dart';

sealed class FavouriteEvent extends Equatable {
  const FavouriteEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FavouritesRequested extends FavouriteEvent {
  const FavouritesRequested();
}

final class FavouriteToggled extends FavouriteEvent {
  const FavouriteToggled(this.propertyId);

  final String propertyId;

  @override
  List<Object?> get props => <Object?>[propertyId];
}
