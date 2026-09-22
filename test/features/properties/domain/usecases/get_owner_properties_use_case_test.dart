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
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession ownerSession = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  late MockPropertyRepository propertyRepository;
  late MockAuthRepository authRepository;
  late GetOwnerPropertiesUseCase useCase;

  setUp(() {
    propertyRepository = MockPropertyRepository();
    authRepository = MockAuthRepository();
    useCase = GetOwnerPropertiesUseCase(
      propertyRepository,
      GetCurrentSessionUseCase(authRepository),
    );
  });

  test('queries only the authenticated owner and sorts newest first', () async {
    final Property older = PropertySeedData.properties[0].toEntity();
    final Property newer = PropertySeedData.properties[1].toEntity();
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
    when(() => propertyRepository.getPropertiesByOwner('O001')).thenAnswer(
      (_) async => Success<List<Property>>(<Property>[older, newer]),
    );

    final Result<List<Property>> result = await useCase();

    expect(
      (result as Success<List<Property>>).data.map((Property item) => item.id),
      <String>['P002', 'P001'],
    );
    verify(() => propertyRepository.getPropertiesByOwner('O001')).called(1);
  });

  test('rejects an unauthenticated request', () async {
    when(authRepository.getCurrentSession).thenAnswer((_) async => null);

    final Result<List<Property>> result = await useCase();

    expect(
      (result as FailureResult<List<Property>>).failure,
      const AuthenticationFailure('You must be signed in as a property owner.'),
    );
    verifyNever(() => propertyRepository.getPropertiesByOwner(any()));
  });

  test('rejects a USER session without querying owner data', () async {
    when(authRepository.getCurrentSession).thenAnswer(
      (_) async => const AuthSession(
        userId: 'U001',
        displayName: 'Demo User',
        role: UserRole.user,
        accessToken: 'token',
      ),
    );

    final Result<List<Property>> result = await useCase();

    expect(
      (result as FailureResult<List<Property>>).failure,
      const AuthenticationFailure(
        'Only property owners can view this dashboard.',
      ),
    );
    verifyNever(() => propertyRepository.getPropertiesByOwner(any()));
  });

  test('propagates repository failures', () async {
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
    when(() => propertyRepository.getPropertiesByOwner('O001')).thenAnswer(
      (_) async => const FailureResult<List<Property>>(
        StorageFailure('Unable to load properties.'),
      ),
    );

    final Result<List<Property>> result = await useCase();

    expect(
      (result as FailureResult<List<Property>>).failure,
      const StorageFailure('Unable to load properties.'),
    );
  });
}
