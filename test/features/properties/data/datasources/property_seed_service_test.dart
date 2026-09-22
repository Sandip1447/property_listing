import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_service.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';

final class MockPropertyLocalDataSource extends Mock
    implements PropertyLocalDataSource {}

void main() {
  late MockPropertyLocalDataSource dataSource;
  late PropertySeedService seedService;

  setUp(() {
    dataSource = MockPropertyLocalDataSource();
    seedService = PropertySeedService(dataSource);
  });

  test(
    'writes deterministic seed data when storage is uninitialized',
    () async {
      when(() => dataSource.isInitialized).thenReturn(false);
      when(
        () => dataSource.saveProperties(PropertySeedData.properties),
      ).thenAnswer((_) async {});

      await seedService.seedIfRequired();

      verify(
        () => dataSource.saveProperties(PropertySeedData.properties),
      ).called(1);
      expect(PropertySeedData.properties, hasLength(10));
    },
  );

  test('does not overwrite an initialized property database', () async {
    when(() => dataSource.isInitialized).thenReturn(true);

    await seedService.seedIfRequired();

    verifyNever(() => dataSource.saveProperties(any<List<PropertyModel>>()));
  });
}
