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
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';

final class MockInterestRepository extends Mock implements InterestRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession ownerSession = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  final PropertyInterest older = PropertyInterest(
    id: 'I001',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please arrange a property viewing.',
    createdAt: DateTime.utc(2026, 9, 21),
  );
  final PropertyInterest newer = PropertyInterest(
    id: 'I002',
    propertyId: 'P002',
    propertyName: 'Palm Grove Villa',
    ownerId: 'O001',
    userId: 'U002',
    fullName: 'Second User',
    mobileNumber: '9123456789',
    email: 'second@example.com',
    message: 'Please send more information about this home.',
    createdAt: DateTime.utc(2026, 9, 22),
  );
  late MockInterestRepository interestRepository;
  late MockAuthRepository authRepository;
  late GetOwnerInterestsUseCase useCase;

  setUp(() {
    interestRepository = MockInterestRepository();
    authRepository = MockAuthRepository();
    useCase = GetOwnerInterestsUseCase(
      interestRepository,
      GetCurrentSessionUseCase(authRepository),
    );
  });

  test('queries only the authenticated owner and sorts newest first', () async {
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
    when(() => interestRepository.getInterestsForOwner('O001')).thenAnswer(
      (_) async =>
          Success<List<PropertyInterest>>(<PropertyInterest>[older, newer]),
    );

    final Result<List<PropertyInterest>> result = await useCase();

    expect(
      (result as Success<List<PropertyInterest>>).data.map(
        (PropertyInterest item) => item.id,
      ),
      <String>['I002', 'I001'],
    );
    verify(() => interestRepository.getInterestsForOwner('O001')).called(1);
  });

  test('rejects a USER session without querying enquiries', () async {
    when(authRepository.getCurrentSession).thenAnswer(
      (_) async => const AuthSession(
        userId: 'U001',
        displayName: 'Demo User',
        role: UserRole.user,
        accessToken: 'token',
      ),
    );

    final Result<List<PropertyInterest>> result = await useCase();

    expect(
      (result as FailureResult<List<PropertyInterest>>).failure,
      const AuthenticationFailure('Only property owners can view enquiries.'),
    );
    verifyNever(() => interestRepository.getInterestsForOwner(any()));
  });

  test('propagates repository failures', () async {
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
    when(() => interestRepository.getInterestsForOwner('O001')).thenAnswer(
      (_) async => const FailureResult<List<PropertyInterest>>(
        StorageFailure('Unable to load interests.'),
      ),
    );

    final Result<List<PropertyInterest>> result = await useCase();

    expect(
      (result as FailureResult<List<PropertyInterest>>).failure,
      const StorageFailure('Unable to load interests.'),
    );
  });
}
