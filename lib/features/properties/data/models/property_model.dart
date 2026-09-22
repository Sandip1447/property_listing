import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

final class PropertyModel {
  const PropertyModel({
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

  factory PropertyModel.fromJson(Map<String, Object?> json) => PropertyModel(
    id: _readString(json, 'id'),
    ownerId: _readString(json, 'ownerId'),
    ownerName: _readString(json, 'ownerName'),
    name: _readString(json, 'name'),
    type: _propertyTypeFromJson(_readString(json, 'type')),
    location: _readString(json, 'location'),
    price: _readDouble(json, 'price'),
    areaSqFt: _readDouble(json, 'areaSqFt'),
    bedrooms: _readInt(json, 'bedrooms'),
    bathrooms: _readInt(json, 'bathrooms'),
    status: _propertyStatusFromJson(_readString(json, 'status')),
    description: _readString(json, 'description'),
    imageUrl: _readString(json, 'imageUrl'),
    createdAt: DateTime.parse(_readString(json, 'createdAt')),
  );

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

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'name': name,
    'type': _propertyTypeToJson(type),
    'location': location,
    'price': price,
    'areaSqFt': areaSqFt,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'status': _propertyStatusToJson(status),
    'description': description,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

String _readString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Expected a string for "$key".');
}

double _readDouble(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is num) {
    return value.toDouble();
  }
  throw FormatException('Expected a number for "$key".');
}

int _readInt(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is int) {
    return value;
  }
  throw FormatException('Expected an integer for "$key".');
}

PropertyType _propertyTypeFromJson(String value) => switch (value) {
  'apartment' => PropertyType.apartment,
  'villa' => PropertyType.villa,
  'row_house' => PropertyType.rowHouse,
  _ => throw FormatException('Unsupported property type: $value'),
};

String _propertyTypeToJson(PropertyType value) => switch (value) {
  PropertyType.apartment => 'apartment',
  PropertyType.villa => 'villa',
  PropertyType.rowHouse => 'row_house',
};

PropertyStatus _propertyStatusFromJson(String value) => switch (value) {
  'available' => PropertyStatus.available,
  'sold' => PropertyStatus.sold,
  'rented' => PropertyStatus.rented,
  'under_construction' => PropertyStatus.underConstruction,
  _ => throw FormatException('Unsupported property status: $value'),
};

String _propertyStatusToJson(PropertyStatus value) => switch (value) {
  PropertyStatus.available => 'available',
  PropertyStatus.sold => 'sold',
  PropertyStatus.rented => 'rented',
  PropertyStatus.underConstruction => 'under_construction',
};
