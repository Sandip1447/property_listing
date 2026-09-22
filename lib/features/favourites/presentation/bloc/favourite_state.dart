import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

enum FavouriteStatus { initial, loading, success, failure }

final class FavouriteState extends Equatable {
  const FavouriteState({
    this.status = FavouriteStatus.initial,
    this.favouriteIds = const <String>{},
    this.properties = const <Property>[],
    this.errorMessage,
  });

  final FavouriteStatus status;
  final Set<String> favouriteIds;
  final List<Property> properties;
  final String? errorMessage;

  List<Property> get favouriteProperties => List<Property>.unmodifiable(
    properties.where((Property property) => favouriteIds.contains(property.id)),
  );

  bool isFavourite(String propertyId) => favouriteIds.contains(propertyId);

  @override
  List<Object?> get props => <Object?>[
    status,
    favouriteIds,
    properties,
    errorMessage,
  ];
}
