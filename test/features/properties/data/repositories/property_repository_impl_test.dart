import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/data/repositories/property_repository_impl.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

final class MockPropertyLocalDataSource extends Mock
    implements PropertyLocalDataSource {}

void main() {
  late MockPropertyLocalDataSource dataSource;
  late PropertyRepositoryImpl repository;

  setUp(() {
    dataSource = MockPropertyLocalDataSource();
    repository = PropertyRepositoryImpl(dataSource);
    when(
      dataSource.getProperties,
    ).thenAnswer((_) async => PropertySeedData.properties);
  });

  setUpAll(() {
    registerFallbackValue(<PropertyModel>[]);
  });

  test('returns all mapped properties', () async {
    final Result<List<Property>> result = await repository.getProperties();

    expect(result, isA<Success<List<Property>>>());
    expect((result as Success<List<Property>>).data, hasLength(10));
  });

  test('finds a property by ID', () async {
    final Result<Property> result = await repository.getPropertyById('P004');

    expect(result, isA<Success<Property>>());
    expect((result as Success<Property>).data.name, 'Royal Row Homes');
  });

  test('returns NotFoundFailure for an unknown property ID', () async {
    final Result<Property> result = await repository.getPropertyById('P999');

    expect(result, isA<FailureResult<Property>>());
    expect((result as FailureResult<Property>).failure, isA<NotFoundFailure>());
  });

  test('returns only properties belonging to the requested owner', () async {
    final Result<List<Property>> result = await repository.getPropertiesByOwner(
      'O001',
    );

    final List<Property> properties = (result as Success<List<Property>>).data;
    expect(properties, hasLength(6));
    expect(properties.every((Property item) => item.ownerId == 'O001'), isTrue);
  });

  test('maps local storage errors to StorageFailure', () async {
    when(
      dataSource.getProperties,
    ).thenThrow(const StorageException('Unable to decode data.'));

    final Result<List<Property>> result = await repository.getProperties();

    expect(
      (result as FailureResult<List<Property>>).failure,
      const StorageFailure('Unable to decode data.'),
    );
  });

  test('adds a property to persisted storage', () async {
    final Property added = PropertySeedData.properties.first.toEntity();
    final Property unique = Property(
      id: 'P011',
      ownerId: added.ownerId,
      ownerName: added.ownerName,
      name: 'New Property',
      type: added.type,
      location: added.location,
      price: added.price,
      areaSqFt: added.areaSqFt,
      bedrooms: added.bedrooms,
      bathrooms: added.bathrooms,
      status: added.status,
      description: added.description,
      imageUrl: added.imageUrl,
      createdAt: added.createdAt,
    );
    when(() => dataSource.saveProperties(any())).thenAnswer((_) async {});

    final Result<Property> result = await repository.addProperty(unique);

    expect(result, Success<Property>(unique));
    final List<PropertyModel> saved =
        verify(() => dataSource.saveProperties(captureAny())).captured.single
            as List<PropertyModel>;
    expect(saved, hasLength(11));
    expect(saved.last.id, 'P011');
  });

  test('updates an existing persisted property', () async {
    final Property original = PropertySeedData.properties.first.toEntity();
    final Property updated = Property(
      id: original.id,
      ownerId: original.ownerId,
      ownerName: original.ownerName,
      name: 'Updated Residence',
      type: original.type,
      location: original.location,
      price: original.price,
      areaSqFt: original.areaSqFt,
      bedrooms: original.bedrooms,
      bathrooms: original.bathrooms,
      status: original.status,
      description: original.description,
      imageUrl: original.imageUrl,
      createdAt: original.createdAt,
    );
    when(() => dataSource.saveProperties(any())).thenAnswer((_) async {});

    final Result<Property> result = await repository.updateProperty(updated);

    expect(result, Success<Property>(updated));
    final List<PropertyModel> saved =
        verify(() => dataSource.saveProperties(captureAny())).captured.single
            as List<PropertyModel>;
    expect(saved.first.name, 'Updated Residence');
  });

  test('deletes an existing property from persisted storage', () async {
    when(() => dataSource.saveProperties(any())).thenAnswer((_) async {});

    final Result<void> result = await repository.deleteProperty('P001');

    expect(result, isA<Success<void>>());
    final List<PropertyModel> saved =
        verify(() => dataSource.saveProperties(captureAny())).captured.single
            as List<PropertyModel>;
    expect(saved, hasLength(9));
    expect(saved.any((PropertyModel item) => item.id == 'P001'), isFalse);
  });
}
