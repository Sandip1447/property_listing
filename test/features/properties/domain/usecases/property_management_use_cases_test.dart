import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/add_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/delete_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/update_property_use_case.dart';
import 'package:uuid/uuid.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession ownerSession = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  const PropertyInput input = PropertyInput(
    name: 'Garden View Home',
    type: PropertyType.villa,
    location: 'Pune',
    price: 12000000,
    areaSqFt: 2100,
    bedrooms: 3,
    bathrooms: 3,
    status: PropertyStatus.available,
    description: 'A spacious home with a landscaped private garden.',
    imageUrl: 'assets/images/property_villa.png',
  );
  final Property fallbackProperty = PropertySeedData.properties.first
      .toEntity();
  late MockPropertyRepository propertyRepository;
  late MockAuthRepository authRepository;
  late GetCurrentSessionUseCase getSession;

  setUpAll(() {
    registerFallbackValue(fallbackProperty);
  });

  setUp(() {
    propertyRepository = MockPropertyRepository();
    authRepository = MockAuthRepository();
    getSession = GetCurrentSessionUseCase(authRepository);
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
  });

  test(
    'add derives owner identity and persists a validated property',
    () async {
      when(() => propertyRepository.addProperty(any())).thenAnswer(
        (Invocation invocation) async => Success<Property>(
          invocation.positionalArguments.single as Property,
        ),
      );

      final Result<Property> result = await AddPropertyUseCase(
        propertyRepository,
        getSession,
        const Uuid(),
      )(input);

      final Property property = (result as Success<Property>).data;
      expect(property.ownerId, ownerSession.userId);
      expect(property.ownerName, ownerSession.displayName);
      expect(property.name, input.name);
      expect(property.id, isNotEmpty);
    },
  );

  test('edit rejects a property belonging to another owner', () async {
    final Property otherOwnerProperty = PropertySeedData.properties[2]
        .toEntity();
    when(
      () => propertyRepository.getPropertyById(otherOwnerProperty.id),
    ).thenAnswer((_) async => Success<Property>(otherOwnerProperty));
    final GetOwnedPropertyByIdUseCase getOwned = GetOwnedPropertyByIdUseCase(
      propertyRepository,
      getSession,
    );

    final Result<Property> result = await UpdatePropertyUseCase(
      propertyRepository,
      getOwned,
    )(propertyId: otherOwnerProperty.id, input: input);

    expect(
      (result as FailureResult<Property>).failure,
      const AuthenticationFailure('You can only edit your own properties.'),
    );
    verifyNever(() => propertyRepository.updateProperty(any()));
  });

  test('delete verifies ownership before repository mutation', () async {
    final Property ownedProperty = fallbackProperty;
    when(
      () => propertyRepository.getPropertyById(ownedProperty.id),
    ).thenAnswer((_) async => Success<Property>(ownedProperty));
    when(
      () => propertyRepository.deleteProperty(ownedProperty.id),
    ).thenAnswer((_) async => const Success<void>(null));

    final Result<void> result = await DeletePropertyUseCase(
      propertyRepository,
      GetOwnedPropertyByIdUseCase(propertyRepository, getSession),
    )(ownedProperty.id);

    expect(result, isA<Success<void>>());
    verify(() => propertyRepository.deleteProperty(ownedProperty.id)).called(1);
  });

  test('add validates property values before reading the session', () async {
    const PropertyInput invalid = PropertyInput(
      name: '',
      type: PropertyType.apartment,
      location: '',
      price: 0,
      areaSqFt: 0,
      bedrooms: 0,
      bathrooms: 0,
      status: PropertyStatus.available,
      description: '',
      imageUrl: '',
    );

    final Result<Property> result = await AddPropertyUseCase(
      propertyRepository,
      getSession,
      const Uuid(),
    )(invalid);

    expect(
      (result as FailureResult<Property>).failure,
      const ValidationFailure('Property name is required.'),
    );
    verifyNever(authRepository.getCurrentSession);
  });
}
