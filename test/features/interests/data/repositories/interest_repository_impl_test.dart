import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/interests/data/datasources/interest_local_data_source.dart';
import 'package:property_listing/features/interests/data/mappers/property_interest_mapper.dart';
import 'package:property_listing/features/interests/data/models/property_interest_model.dart';
import 'package:property_listing/features/interests/data/repositories/interest_repository_impl.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';

final class MockInterestLocalDataSource extends Mock
    implements InterestLocalDataSource {}

void main() {
  final PropertyInterestModel older = PropertyInterestModel(
    id: 'I001',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please share a suitable time for a visit.',
    createdAt: DateTime.utc(2026, 9, 21),
  );
  final PropertyInterestModel newer = PropertyInterestModel(
    id: 'I002',
    propertyId: 'P002',
    propertyName: 'Palm Grove Villa',
    ownerId: 'O001',
    userId: 'U002',
    fullName: 'Second User',
    mobileNumber: '9123456789',
    email: 'second@example.com',
    message: 'Please send me more information about this home.',
    createdAt: DateTime.utc(2026, 9, 22),
  );
  final PropertyInterestModel anotherOwner = PropertyInterestModel(
    id: 'I003',
    propertyId: 'P003',
    propertyName: 'Lakeview Heights',
    ownerId: 'O002',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Could I arrange a viewing next weekend?',
    createdAt: DateTime.utc(2026, 9, 23),
  );
  late MockInterestLocalDataSource dataSource;
  late InterestRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(older);
  });

  setUp(() {
    dataSource = MockInterestLocalDataSource();
    repository = InterestRepositoryImpl(dataSource);
  });

  test('submits a mapped interest through the local data source', () async {
    when(() => dataSource.addInterest(any())).thenAnswer((_) async => older);

    final Result<PropertyInterest> result = await repository.submitInterest(
      older.toEntity(),
    );

    expect(result, Success<PropertyInterest>(older.toEntity()));
    verify(() => dataSource.addInterest(any())).called(1);
  });

  test('returns only owner interests sorted newest first', () async {
    when(dataSource.getInterests).thenAnswer(
      (_) async => <PropertyInterestModel>[older, anotherOwner, newer],
    );

    final Result<List<PropertyInterest>> result = await repository
        .getInterestsForOwner('O001');

    final List<PropertyInterest> interests =
        (result as Success<List<PropertyInterest>>).data;
    expect(interests.map((PropertyInterest item) => item.id), <String>[
      'I002',
      'I001',
    ]);
  });

  test('returns only interests for the requested property', () async {
    when(
      dataSource.getInterests,
    ).thenAnswer((_) async => <PropertyInterestModel>[older, newer]);

    final Result<List<PropertyInterest>> result = await repository
        .getInterestsForProperty('P002');

    expect((result as Success<List<PropertyInterest>>).data.single.id, 'I002');
  });

  test('maps local storage errors to StorageFailure', () async {
    when(
      dataSource.getInterests,
    ).thenThrow(const StorageException('Unable to read interests.'));

    final Result<List<PropertyInterest>> result = await repository
        .getInterestsForOwner('O001');

    expect(
      (result as FailureResult<List<PropertyInterest>>).failure,
      const StorageFailure('Unable to read interests.'),
    );
  });
}
