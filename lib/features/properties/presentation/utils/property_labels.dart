import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

extension PropertyTypeLabel on PropertyType {
  String get label => switch (this) {
    PropertyType.apartment => 'Apartment',
    PropertyType.villa => 'Villa',
    PropertyType.rowHouse => 'Row House',
  };
}

extension PropertyStatusLabel on PropertyStatus {
  String get label => switch (this) {
    PropertyStatus.available => 'Available',
    PropertyStatus.sold => 'Sold',
    PropertyStatus.rented => 'Rented',
    PropertyStatus.underConstruction => 'Under Construction',
  };
}

extension PropertySortLabel on PropertySort {
  String get label => switch (this) {
    PropertySort.newest => 'Newest',
    PropertySort.priceLowToHigh => 'Price: Low to High',
    PropertySort.priceHighToLow => 'Price: High to Low',
    PropertySort.areaLowToHigh => 'Area: Low to High',
    PropertySort.areaHighToLow => 'Area: High to Low',
  };
}
