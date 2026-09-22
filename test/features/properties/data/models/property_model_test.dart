import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

void main() {
  final PropertyModel model = PropertyModel(
    id: 'P100',
    ownerId: 'O100',
    ownerName: 'Test Owner',
    name: 'Test Row Home',
    type: PropertyType.rowHouse,
    location: 'Pune',
    price: 12300000,
    areaSqFt: 1750,
    bedrooms: 3,
    bathrooms: 2,
    status: PropertyStatus.underConstruction,
    description: 'A property used only by unit tests.',
    imageUrl: 'assets/images/property_placeholder.png',
    createdAt: DateTime.utc(2026, 7, 1),
  );

  test('serializes enums with explicit stable values', () {
    final Map<String, Object?> json = model.toJson();

    expect(json['type'], 'row_house');
    expect(json['status'], 'under_construction');
    expect(json['createdAt'], '2026-07-01T00:00:00.000Z');
  });

  test('round-trips JSON without losing property data', () {
    final PropertyModel restored = PropertyModel.fromJson(model.toJson());

    expect(restored.id, model.id);
    expect(restored.type, model.type);
    expect(restored.price, model.price);
    expect(restored.status, model.status);
    expect(restored.createdAt, model.createdAt);
  });

  test('maps between data model and domain entity', () {
    final Property entity = model.toEntity();

    expect(entity.name, model.name);
    expect(entity.toModel().toJson(), model.toJson());
  });

  test('rejects unknown serialized enum values', () {
    final Map<String, Object?> json = model.toJson()..['type'] = 'farm_house';

    expect(() => PropertyModel.fromJson(json), throwsFormatException);
  });
}
