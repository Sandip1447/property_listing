import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    service = SharedPreferencesService(preferences);
  });

  test('stores and reads strings', () async {
    await service.setString('key', 'value');

    expect(service.getString('key'), 'value');
  });

  test('stores and reads string lists', () async {
    await service.setStringList('key', <String>['one', 'two']);

    expect(service.getStringList('key'), <String>['one', 'two']);
  });

  test('removes stored values', () async {
    await service.setString('key', 'value');
    await service.remove('key');

    expect(service.getString('key'), isNull);
  });
}
