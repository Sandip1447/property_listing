import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

final class Property extends Equatable {
  const Property({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.areaSqFt,
    required this.bedrooms,
    required this.bathrooms,
    required this.status,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final PropertyType type;
  final String location;
  final double price;
  final double areaSqFt;
  final int bedrooms;
  final int bathrooms;
  final PropertyStatus status;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    ownerId,
    ownerName,
    name,
    type,
    location,
    price,
    areaSqFt,
    bedrooms,
    bathrooms,
    status,
    description,
    imageUrl,
    createdAt,
  ];
}
