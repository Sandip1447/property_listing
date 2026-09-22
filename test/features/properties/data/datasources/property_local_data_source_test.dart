import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late PropertyLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesPropertyLocalDataSource(
      SharedPreferencesService(preferences),
    );
  });

  test('reports uninitialized storage when no property JSON exists', () {
    expect(dataSource.isInitialized, isFalse);
  });

  test('persists and restores property models as JSON', () async {
    await dataSource.saveProperties(PropertySeedData.properties);

    final List<PropertyModel> restored = await dataSource.getProperties();

    expect(dataSource.isInitialized, isTrue);
    expect(restored, hasLength(10));
    expect(restored.first.id, 'P001');
    expect(restored.last.id, 'P010');
  });

  test('converts malformed persisted JSON into StorageException', () async {
    await preferences.setString(StorageKeys.propertiesJson, '{not-json}');

    expect(dataSource.getProperties, throwsA(isA<StorageException>()));
  });
}
