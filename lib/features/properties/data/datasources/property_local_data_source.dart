import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';

abstract interface class PropertyLocalDataSource {
  bool get isInitialized;

  Future<List<PropertyModel>> getProperties();

  Future<void> saveProperties(List<PropertyModel> properties);
}

@LazySingleton(as: PropertyLocalDataSource)
final class SharedPreferencesPropertyLocalDataSource
    implements PropertyLocalDataSource {
  const SharedPreferencesPropertyLocalDataSource(this._preferences);

  final PreferencesService _preferences;

  @override
  bool get isInitialized =>
      _preferences.getString(StorageKeys.propertiesJson) != null;

  @override
  Future<List<PropertyModel>> getProperties() async {
    final String? encoded = _preferences.getString(StorageKeys.propertiesJson);
    if (encoded == null) {
      return const <PropertyModel>[];
    }

    try {
      final Object? decoded = jsonDecode(encoded) as Object?;
      if (decoded is! List<Object?>) {
        throw const FormatException('Property data must be a JSON list.');
      }

      return List<PropertyModel>.unmodifiable(
        decoded.map((Object? item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Each property must be a JSON object.');
          }
          return PropertyModel.fromJson(item);
        }),
      );
    } on Object catch (error) {
      throw StorageException('Unable to read saved properties: $error');
    }
  }

  @override
  Future<void> saveProperties(List<PropertyModel> properties) async {
    try {
      final String encoded = jsonEncode(
        properties
            .map((PropertyModel property) => property.toJson())
            .toList(growable: false),
      );
      await _preferences.setString(StorageKeys.propertiesJson, encoded);
    } on Object catch (error) {
      throw StorageException('Unable to save properties: $error');
    }
  }
}
