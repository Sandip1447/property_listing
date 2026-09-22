import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

final class PropertyFilter extends Equatable {
  const PropertyFilter({
    this.query = '',
    this.location,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.status,
    this.bedrooms,
    this.sort,
  });

  final String query;
  final String? location;
  final PropertyType? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final PropertyStatus? status;
  final int? bedrooms;
  final PropertySort? sort;

  PropertyFilter copyWith({
    String? query,
    String? location,
    PropertyType? propertyType,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    PropertyStatus? status,
    int? bedrooms,
    PropertySort? sort,
  }) => PropertyFilter(
    query: query ?? this.query,
    location: location ?? this.location,
    propertyType: propertyType ?? this.propertyType,
    minPrice: minPrice ?? this.minPrice,
    maxPrice: maxPrice ?? this.maxPrice,
    minArea: minArea ?? this.minArea,
    maxArea: maxArea ?? this.maxArea,
    status: status ?? this.status,
    bedrooms: bedrooms ?? this.bedrooms,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => <Object?>[
    query,
    location,
    propertyType,
    minPrice,
    maxPrice,
    minArea,
    maxArea,
    status,
    bedrooms,
    sort,
  ];
}
