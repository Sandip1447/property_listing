import 'package:injectable/injectable.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';

@lazySingleton
final class FilterPropertiesUseCase {
  const FilterPropertiesUseCase();

  List<Property> call({
    required List<Property> properties,
    required PropertyFilter filter,
  }) {
    final String query = _normalize(filter.query);
    final String? location = filter.location == null
        ? null
        : _normalize(filter.location!);
    final List<Property> filtered = properties.where((Property property) {
      final bool matchesQuery =
          query.isEmpty ||
          _normalize(property.name).contains(query) ||
          _normalize(property.location).contains(query);
      final bool matchesLocation =
          location == null || _normalize(property.location) == location;
      final bool matchesType =
          filter.propertyType == null || property.type == filter.propertyType;
      final bool matchesMinPrice =
          filter.minPrice == null || property.price >= filter.minPrice!;
      final bool matchesMaxPrice =
          filter.maxPrice == null || property.price <= filter.maxPrice!;
      final bool matchesMinArea =
          filter.minArea == null || property.areaSqFt >= filter.minArea!;
      final bool matchesMaxArea =
          filter.maxArea == null || property.areaSqFt <= filter.maxArea!;
      final bool matchesStatus =
          filter.status == null || property.status == filter.status;
      final bool matchesBedrooms =
          filter.bedrooms == null || property.bedrooms == filter.bedrooms;

      return matchesQuery &&
          matchesLocation &&
          matchesType &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesMinArea &&
          matchesMaxArea &&
          matchesStatus &&
          matchesBedrooms;
    }).toList();

    switch (filter.sort) {
      case PropertySort.newest:
        filtered.sort(
          (Property first, Property second) =>
              second.createdAt.compareTo(first.createdAt),
        );
      case PropertySort.priceLowToHigh:
        filtered.sort(
          (Property first, Property second) =>
              first.price.compareTo(second.price),
        );
      case PropertySort.priceHighToLow:
        filtered.sort(
          (Property first, Property second) =>
              second.price.compareTo(first.price),
        );
      case PropertySort.areaLowToHigh:
        filtered.sort(
          (Property first, Property second) =>
              first.areaSqFt.compareTo(second.areaSqFt),
        );
      case PropertySort.areaHighToLow:
        filtered.sort(
          (Property first, Property second) =>
              second.areaSqFt.compareTo(first.areaSqFt),
        );
      case null:
        break;
    }

    return List<Property>.unmodifiable(filtered);
  }

  String _normalize(String value) => value.trim().toLowerCase();
}
