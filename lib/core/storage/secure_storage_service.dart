import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/constants/storage_keys.dart';

abstract interface class SecureStorageService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<void> clearSession();
}

@LazySingleton(as: SecureStorageService)
final class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> clearSession() async {
    await Future.wait(
      StorageKeys.sessionKeys.map((String key) => _storage.delete(key: key)),
    );
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
