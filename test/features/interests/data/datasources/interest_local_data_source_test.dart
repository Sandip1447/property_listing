import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/interests/data/datasources/interest_local_data_source.dart';
import 'package:property_listing/features/interests/data/models/property_interest_model.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final PropertyInterestModel interest = PropertyInterestModel(
    id: 'I001',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please share a suitable time for a visit.',
    createdAt: DateTime.utc(2026, 9, 22, 10, 30),
  );
  late SharedPreferences preferences;
  late InterestLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesInterestLocalDataSource(
      SharedPreferencesService(preferences),
    );
  });

  test('returns an empty list before the first submission', () async {
    expect(await dataSource.getInterests(), isEmpty);
  });

  test('persists a submission and restores it from JSON', () async {
    await dataSource.addInterest(interest);

    final List<PropertyInterestModel> restored =
        await SharedPreferencesInterestLocalDataSource(
          SharedPreferencesService(preferences),
        ).getInterests();

    expect(restored, hasLength(1));
    expect(restored.single.toJson(), interest.toJson());
    expect(
      preferences.getString(StorageKeys.interestsJson),
      contains('Green Valley Residency'),
    );
  });

  test('appends submissions without replacing existing data', () async {
    await dataSource.addInterest(interest);
    await dataSource.addInterest(
      PropertyInterestModel(
        id: 'I002',
        propertyId: 'P002',
        propertyName: 'Palm Grove Villa',
        ownerId: 'O001',
        userId: 'U002',
        fullName: 'Another User',
        mobileNumber: '9123456789',
        email: 'another@example.com',
        message: 'I would like additional details, please.',
        createdAt: DateTime.utc(2026, 9, 22, 11),
      ),
    );

    expect(await dataSource.getInterests(), hasLength(2));
  });

  test('persists an updated enquiry status', () async {
    await dataSource.addInterest(interest);

    await dataSource.updateInterestStatus(
      interest.id,
      InterestStatus.contacted,
    );

    final PropertyInterestModel restored = (await dataSource.getInterests())
        .single;
    expect(restored.status, InterestStatus.contacted);
  });

  test('converts malformed JSON into a StorageException', () async {
    await preferences.setString(StorageKeys.interestsJson, '{invalid-json}');

    expect(dataSource.getInterests, throwsA(isA<StorageException>()));
  });
}
