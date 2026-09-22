import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

extension PropertyModelMapper on PropertyModel {
  Property toEntity() => Property(
    id: id,
    ownerId: ownerId,
    ownerName: ownerName,
    name: name,
    type: type,
    location: location,
    price: price,
    areaSqFt: areaSqFt,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    status: status,
    description: description,
    imageUrl: imageUrl,
    createdAt: createdAt,
  );
}

extension PropertyEntityMapper on Property {
  PropertyModel toModel() => PropertyModel(
    id: id,
    ownerId: ownerId,
    ownerName: ownerName,
    name: name,
    type: type,
    location: location,
    price: price,
    areaSqFt: areaSqFt,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    status: status,
    description: description,
    imageUrl: imageUrl,
    createdAt: createdAt,
  );
}
