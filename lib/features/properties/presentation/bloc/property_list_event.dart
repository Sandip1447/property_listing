import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';

sealed class PropertyListEvent extends Equatable {
  const PropertyListEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PropertyListRequested extends PropertyListEvent {
  const PropertyListRequested();
}

final class PropertySearchChanged extends PropertyListEvent {
  const PropertySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class PropertyFiltersChanged extends PropertyListEvent {
  const PropertyFiltersChanged(this.filter);

  final PropertyFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

final class PropertyFiltersCleared extends PropertyListEvent {
  const PropertyFiltersCleared();
}

final class PropertySortChanged extends PropertyListEvent {
  const PropertySortChanged(this.sort);

  final PropertySort sort;

  @override
  List<Object?> get props => <Object?>[sort];
}

final class PropertyListRefreshed extends PropertyListEvent {
  const PropertyListRefreshed();
}
