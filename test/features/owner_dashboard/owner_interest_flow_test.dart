import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/data/datasources/interest_local_data_source.dart';
import 'package:property_listing/features/interests/data/repositories/interest_repository_impl.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/interests/domain/usecases/update_interest_status_use_case.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/repositories/property_repository_impl.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test(
    'persisted USER interests are visible only to the matching owner',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final PreferencesService preferencesService = SharedPreferencesService(
        preferences,
      );
      final SharedPreferencesPropertyLocalDataSource propertyDataSource =
          SharedPreferencesPropertyLocalDataSource(preferencesService);
      await propertyDataSource.saveProperties(PropertySeedData.properties);
      final PropertyRepositoryImpl propertyRepository = PropertyRepositoryImpl(
        propertyDataSource,
      );
      final InterestRepositoryImpl interestRepository = InterestRepositoryImpl(
        SharedPreferencesInterestLocalDataSource(preferencesService),
      );
      final MockAuthRepository authRepository = MockAuthRepository();
      AuthSession activeSession = const AuthSession(
        userId: 'U001',
        displayName: 'Demo User',
        role: UserRole.user,
        accessToken: 'user-token',
      );
      when(
        authRepository.getCurrentSession,
      ).thenAnswer((_) async => activeSession);
      final GetCurrentSessionUseCase getSession = GetCurrentSessionUseCase(
        authRepository,
      );
      final SubmitInterestUseCase submitInterest = SubmitInterestUseCase(
        interestRepository,
        GetPropertyByIdUseCase(propertyRepository),
        getSession,
        const Uuid(),
      );

      await submitInterest(
        propertyId: 'P001',
        fullName: 'Demo User',
        mobileNumber: '9876543210',
        email: 'user@propertydemo.com',
        message: 'I would like to visit this Pune property.',
      );
      await submitInterest(
        propertyId: 'P003',
        fullName: 'Demo User',
        mobileNumber: '9876543210',
        email: 'user@propertydemo.com',
        message: 'I would also like to visit this Mumbai property.',
      );

      activeSession = const AuthSession(
        userId: 'O001',
        displayName: 'Demo Owner',
        role: UserRole.propertyOwner,
        accessToken: 'owner-token',
      );
      final Result<List<PropertyInterest>> interestResult =
          await GetOwnerInterestsUseCase(interestRepository, getSession)();
      final Result<List<Property>> propertyResult =
          await GetOwnerPropertiesUseCase(propertyRepository, getSession)();

      final List<PropertyInterest> ownerInterests =
          (interestResult as Success<List<PropertyInterest>>).data;
      final List<Property> ownerProperties =
          (propertyResult as Success<List<Property>>).data;
      expect(ownerInterests, hasLength(1));
      expect(ownerInterests.single.propertyId, 'P001');
      expect(ownerInterests.single.ownerId, 'O001');
      expect(
        ownerProperties.every(
          (Property property) => property.ownerId == 'O001',
        ),
        isTrue,
      );
      expect(ownerProperties, hasLength(6));

      final PropertyInterest ownerInterest = ownerInterests.single;
      final UpdateInterestStatusUseCase updateStatus =
          UpdateInterestStatusUseCase(interestRepository, getSession);
      final Result<PropertyInterest> updateResult = await updateStatus(
        interestId: ownerInterest.id,
        status: InterestStatus.contacted,
      );
      expect(
        (updateResult as Success<PropertyInterest>).data.status,
        InterestStatus.contacted,
      );

      final Result<List<PropertyInterest>> restoredResult =
          await interestRepository.getInterestsForOwner('O001');
      expect(
        (restoredResult as Success<List<PropertyInterest>>).data.single.status,
        InterestStatus.contacted,
      );

      activeSession = const AuthSession(
        userId: 'U001',
        displayName: 'Demo User',
        role: UserRole.user,
        accessToken: 'user-token',
      );
      final Result<PropertyInterest> unauthorizedResult = await updateStatus(
        interestId: ownerInterest.id,
        status: InterestStatus.closed,
      );
      expect(unauthorizedResult, isA<FailureResult<PropertyInterest>>());
    },
  );
}
