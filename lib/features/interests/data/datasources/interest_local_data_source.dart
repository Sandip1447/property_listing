import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/interests/data/models/property_interest_model.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';

abstract interface class InterestLocalDataSource {
  Future<PropertyInterestModel> addInterest(PropertyInterestModel interest);

  Future<List<PropertyInterestModel>> getInterests();

  Future<PropertyInterestModel?> updateInterestStatus(
    String interestId,
    InterestStatus status,
  );
}

@LazySingleton(as: InterestLocalDataSource)
final class SharedPreferencesInterestLocalDataSource
    implements InterestLocalDataSource {
  const SharedPreferencesInterestLocalDataSource(this._preferences);

  final PreferencesService _preferences;

  @override
  Future<PropertyInterestModel> addInterest(
    PropertyInterestModel interest,
  ) async {
    final List<PropertyInterestModel> interests = await getInterests();
    final List<PropertyInterestModel> updated = <PropertyInterestModel>[
      ...interests,
      interest,
    ];

    try {
      await _preferences.setString(
        StorageKeys.interestsJson,
        jsonEncode(
          updated
              .map((PropertyInterestModel item) => item.toJson())
              .toList(growable: false),
        ),
      );
      return interest;
    } on Object catch (error) {
      throw StorageException('Unable to save property interest: $error');
    }
  }

  @override
  Future<List<PropertyInterestModel>> getInterests() async {
    try {
      final String? encoded = _preferences.getString(StorageKeys.interestsJson);
      if (encoded == null) {
        return const <PropertyInterestModel>[];
      }
      final Object? decoded = jsonDecode(encoded) as Object?;
      if (decoded is! List<Object?>) {
        throw const FormatException('Interest data must be a JSON list.');
      }
      return List<PropertyInterestModel>.unmodifiable(
        decoded.map((Object? item) {
          if (item is! Map<String, Object?>) {
            throw const FormatException('Each interest must be a JSON object.');
          }
          return PropertyInterestModel.fromJson(item);
        }),
      );
    } on Object catch (error) {
      throw StorageException('Unable to read property interests: $error');
    }

  }

  @override
  Future<PropertyInterestModel?> updateInterestStatus(
    String interestId,
    InterestStatus status,
  ) async {
    final List<PropertyInterestModel> interests = await getInterests();
    PropertyInterestModel? updatedInterest;
    final List<PropertyInterestModel> updated = interests.map((
      PropertyInterestModel interest,
    ) {
      if (interest.id != interestId) {
        return interest;
      }
      updatedInterest = PropertyInterestModel(
        id: interest.id,
        propertyId: interest.propertyId,
        propertyName: interest.propertyName,
        ownerId: interest.ownerId,
        userId: interest.userId,
        fullName: interest.fullName,
        mobileNumber: interest.mobileNumber,
        email: interest.email,
        message: interest.message,
        createdAt: interest.createdAt,
        status: status,
      );
      return updatedInterest!;
    }).toList(growable: false);
    if (updatedInterest == null) {
      return null;
    }
    try {
      await _preferences.setString(
        StorageKeys.interestsJson,
        jsonEncode(
          updated.map((PropertyInterestModel item) => item.toJson()).toList(),
        ),
      );
      return updatedInterest;
    } on Object catch (error) {
      throw StorageException('Unable to update property interest: $error');
    }
  }
}
