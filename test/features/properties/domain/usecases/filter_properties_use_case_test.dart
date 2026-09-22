import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/domain/usecases/filter_properties_use_case.dart';

void main() {
  const FilterPropertiesUseCase filterProperties = FilterPropertiesUseCase();
  final List<Property> properties = PropertySeedData.properties
      .map((PropertyModel model) => model.toEntity())
      .toList(growable: false);

  test('matches query against name and location without case sensitivity', () {
    final List<Property> nameResult = filterProperties(
      properties: properties,
      filter: const PropertyFilter(query: 'green valley'),
    );
    final List<Property> locationResult = filterProperties(
      properties: properties,
      filter: const PropertyFilter(query: 'NAVI MUMBAI'),
    );

    expect(nameResult.single.id, 'P001');
    expect(locationResult.single.id, 'P007');
  });

  test('combines every active criterion with AND semantics', () {
    final List<Property> result = filterProperties(
      properties: properties,
      filter: const PropertyFilter(
        query: 'skyline',
        location: ' pune ',
        propertyType: PropertyType.apartment,
        minPrice: 12000000,
        maxPrice: 13000000,
        minArea: 1400,
        maxArea: 1500,
        status: PropertyStatus.underConstruction,
        bedrooms: 3,
      ),
    );

    expect(result.single.id, 'P009');
  });

  test('uses inclusive price and area boundaries', () {
    final Property property = properties.first;
    final List<Property> result = filterProperties(
      properties: properties,
      filter: PropertyFilter(
        minPrice: property.price,
        maxPrice: property.price,
        minArea: property.areaSqFt,
        maxArea: property.areaSqFt,
      ),
    );

    expect(result.single.id, property.id);
  });

  test('sorts by newest, price, and area without mutating source data', () {
    final List<String> originalOrder = properties
        .map((Property property) => property.id)
        .toList(growable: false);

    final List<Property> newest = filterProperties(
      properties: properties,
      filter: const PropertyFilter(sort: PropertySort.newest),
    );
    final List<Property> cheapest = filterProperties(
      properties: properties,
      filter: const PropertyFilter(sort: PropertySort.priceLowToHigh),
    );
    final List<Property> largest = filterProperties(
      properties: properties,
      filter: const PropertyFilter(sort: PropertySort.areaHighToLow),
    );

    expect(newest.first.id, 'P010');
    expect(cheapest.first.id, 'P001');
    expect(largest.first.id, 'P006');
    expect(properties.map((Property property) => property.id), originalOrder);
  });

  test('returns an empty list when combined filters do not match', () {
    final List<Property> result = filterProperties(
      properties: properties,
      filter: const PropertyFilter(
        location: 'Mumbai',
        propertyType: PropertyType.villa,
      ),
    );

    expect(result, isEmpty);
  });
}
