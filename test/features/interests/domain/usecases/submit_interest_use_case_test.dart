import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:uuid/uuid.dart';

final class MockInterestRepository extends Mock implements InterestRepository {}

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final Property property = PropertySeedData.properties.first.toEntity();
  const AuthSession userSession = AuthSession(
    userId: 'U001',
    displayName: 'Demo User',
    role: UserRole.user,
    accessToken: 'token',
  );
  final PropertyInterest fallbackInterest = PropertyInterest(
    id: 'fallback',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please arrange a property viewing.',
    createdAt: DateTime.utc(2026),
  );
  late MockInterestRepository interestRepository;
  late MockPropertyRepository propertyRepository;
  late MockAuthRepository authRepository;
  late SubmitInterestUseCase useCase;

  setUpAll(() {
    registerFallbackValue(fallbackInterest);
  });

  setUp(() {
    interestRepository = MockInterestRepository();
    propertyRepository = MockPropertyRepository();
    authRepository = MockAuthRepository();
    useCase = SubmitInterestUseCase(
      interestRepository,
      GetPropertyByIdUseCase(propertyRepository),
      GetCurrentSessionUseCase(authRepository),
      const Uuid(),
    );
  });

  test('derives property and session fields before persistence', () async {
    when(
      () => propertyRepository.getPropertyById('P001'),
    ).thenAnswer((_) async => Success<Property>(property));
    when(authRepository.getCurrentSession).thenAnswer((_) async => userSession);
    when(() => interestRepository.submitInterest(any())).thenAnswer(
      (Invocation invocation) async => Success<PropertyInterest>(
        invocation.positionalArguments.single as PropertyInterest,
      ),
    );

    final Result<PropertyInterest> result = await useCase(
      propertyId: 'P001',
      fullName: '  Demo User  ',
      mobileNumber: '9876543210',
      email: ' user@propertydemo.com ',
      message: '  Please arrange a property viewing.  ',
    );

    final PropertyInterest interest =
        (result as Success<PropertyInterest>).data;
    expect(interest.id, isNotEmpty);
    expect(interest.propertyId, property.id);
    expect(interest.propertyName, property.name);
    expect(interest.ownerId, property.ownerId);
    expect(interest.userId, userSession.userId);
    expect(interest.fullName, 'Demo User');
    expect(interest.email, 'user@propertydemo.com');
    expect(interest.message, 'Please arrange a property viewing.');
  });

  test('rejects invalid fields before loading property or session', () async {
    final Result<PropertyInterest> result = await useCase(
      propertyId: 'P001',
      fullName: 'A',
      mobileNumber: 'bad',
      email: 'bad',
      message: 'short',
    );

    expect(
      (result as FailureResult<PropertyInterest>).failure,
      const ValidationFailure('Full name must contain at least 2 characters.'),
    );
    verifyNever(() => propertyRepository.getPropertyById(any()));
    verifyNever(authRepository.getCurrentSession);
  });

  test('propagates a missing-property failure', () async {
    when(() => propertyRepository.getPropertyById('P999')).thenAnswer(
      (_) async => const FailureResult<Property>(
        NotFoundFailure('Property "P999" was not found.'),
      ),
    );

    final Result<PropertyInterest> result = await useCase(
      propertyId: 'P999',
      fullName: 'Demo User',
      mobileNumber: '9876543210',
      email: 'user@propertydemo.com',
      message: 'Please arrange a property viewing.',
    );

    expect(
      (result as FailureResult<PropertyInterest>).failure,
      const NotFoundFailure('Property "P999" was not found.'),
    );
  });

  test('rejects a property-owner session', () async {
    when(
      () => propertyRepository.getPropertyById('P001'),
    ).thenAnswer((_) async => Success<Property>(property));
    when(authRepository.getCurrentSession).thenAnswer(
      (_) async => const AuthSession(
        userId: 'O001',
        displayName: 'Demo Owner',
        role: UserRole.propertyOwner,
        accessToken: 'token',
      ),
    );

    final Result<PropertyInterest> result = await useCase(
      propertyId: 'P001',
      fullName: 'Demo Owner',
      mobileNumber: '9876543210',
      email: 'owner@propertydemo.com',
      message: 'Please arrange a property viewing.',
    );

    expect(
      (result as FailureResult<PropertyInterest>).failure,
      const AuthenticationFailure('Only users can submit property interests.'),
    );
    verifyNever(() => interestRepository.submitInterest(any()));
  });

  test('rejects rented properties at the domain boundary', () async {
    final Property rented = Property(
      id: property.id,
      ownerId: property.ownerId,
      ownerName: property.ownerName,
      name: property.name,
      type: property.type,
      location: property.location,
      price: property.price,
      areaSqFt: property.areaSqFt,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      status: PropertyStatus.rented,
      description: property.description,
      imageUrl: property.imageUrl,
      createdAt: property.createdAt,
    );
    when(
      () => propertyRepository.getPropertyById('P001'),
    ).thenAnswer((_) async => Success<Property>(rented));

    final Result<PropertyInterest> result = await useCase(
      propertyId: 'P001',
      fullName: 'Demo User',
      mobileNumber: '9876543210',
      email: 'user@propertydemo.com',
      message: 'Please arrange a property viewing.',
    );

    expect(
      (result as FailureResult<PropertyInterest>).failure,
      const ValidationFailure(
        'Interest cannot be submitted for this property.',
      ),
    );
    verifyNever(authRepository.getCurrentSession);
  });
}
