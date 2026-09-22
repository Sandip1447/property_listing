import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/storage/secure_storage_service.dart';

final class MockFlutterSecureStorage extends Mock
    implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  late SecureStorageService service;

  setUp(() {
    storage = MockFlutterSecureStorage();
    service = FlutterSecureStorageService(storage);
  });

  test('delegates reads and writes', () async {
    when(
      () => storage.write(key: 'key', value: 'value'),
    ).thenAnswer((_) async {});
    when(() => storage.read(key: 'key')).thenAnswer((_) async => 'value');

    await service.write('key', 'value');

    expect(await service.read('key'), 'value');
    verify(() => storage.write(key: 'key', value: 'value')).called(1);
  });

  test('clearSession deletes only sensitive session values', () async {
    for (final String key in StorageKeys.sessionKeys) {
      when(() => storage.delete(key: key)).thenAnswer((_) async {});
    }

    await service.clearSession();

    for (final String key in StorageKeys.sessionKeys) {
      verify(() => storage.delete(key: key)).called(1);
    }
    verifyNever(() => storage.deleteAll());
  });
}
