import 'package:bloc_test/bloc_test.dart';
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
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_event.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_state.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:uuid/uuid.dart';

final class MockInterestRepository extends Mock implements InterestRepository {}

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final Property property = PropertySeedData.properties.first.toEntity();
  const AuthSession session = AuthSession(
    userId: 'U001',
    displayName: 'Demo User',
    role: UserRole.user,
    accessToken: 'token',
  );
  final PropertyInterest savedInterest = PropertyInterest(
    id: 'I001',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please arrange a property viewing.',
    createdAt: DateTime.utc(2026, 9, 22),
  );
  late MockInterestRepository interestRepository;
  late MockPropertyRepository propertyRepository;
  late MockAuthRepository authRepository;

  setUpAll(() {
    registerFallbackValue(savedInterest);
  });

  setUp(() {
    interestRepository = MockInterestRepository();
    propertyRepository = MockPropertyRepository();
    authRepository = MockAuthRepository();
  });

  SubmitInterestBloc buildBloc() => SubmitInterestBloc(
    SubmitInterestUseCase(
      interestRepository,
      GetPropertyByIdUseCase(propertyRepository),
      GetCurrentSessionUseCase(authRepository),
      const Uuid(),
    ),
  );

  const SubmitInterestSubmitted submission = SubmitInterestSubmitted(
    propertyId: 'P001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please arrange a property viewing.',
  );

  blocTest<SubmitInterestBloc, SubmitInterestState>(
    'emits submitting then success for a valid submission',
    setUp: () {
      when(
        () => propertyRepository.getPropertyById('P001'),
      ).thenAnswer((_) async => Success<Property>(property));
      when(authRepository.getCurrentSession).thenAnswer((_) async => session);
      when(
        () => interestRepository.submitInterest(any()),
      ).thenAnswer((_) async => Success<PropertyInterest>(savedInterest));
    },
    build: buildBloc,
    act: (SubmitInterestBloc bloc) => bloc.add(submission),
    expect: () => <SubmitInterestState>[
      const SubmitInterestState(status: SubmitInterestStatus.submitting),
      SubmitInterestState(
        status: SubmitInterestStatus.success,
        interest: savedInterest,
      ),
    ],
  );

  blocTest<SubmitInterestBloc, SubmitInterestState>(
    'emits submitting then failure for invalid input',
    build: buildBloc,
    act: (SubmitInterestBloc bloc) => bloc.add(
      const SubmitInterestSubmitted(
        propertyId: 'P001',
        fullName: '',
        mobileNumber: '',
        email: '',
        message: '',
      ),
    ),
    expect: () => const <SubmitInterestState>[
      SubmitInterestState(status: SubmitInterestStatus.submitting),
      SubmitInterestState(
        status: SubmitInterestStatus.failure,
        errorMessage: 'Full name is required.',
      ),
    ],
    verify: (SubmitInterestBloc bloc) {
      verifyNever(() => interestRepository.submitInterest(any()));
    },
  );

  blocTest<SubmitInterestBloc, SubmitInterestState>(
    'surfaces repository failures',
    setUp: () {
      when(
        () => propertyRepository.getPropertyById('P001'),
      ).thenAnswer((_) async => Success<Property>(property));
      when(authRepository.getCurrentSession).thenAnswer((_) async => session);
      when(() => interestRepository.submitInterest(any())).thenAnswer(
        (_) async => const FailureResult<PropertyInterest>(
          StorageFailure('Unable to save property interest.'),
        ),
      );
    },
    build: buildBloc,
    act: (SubmitInterestBloc bloc) => bloc.add(submission),
    expect: () => const <SubmitInterestState>[
      SubmitInterestState(status: SubmitInterestStatus.submitting),
      SubmitInterestState(
        status: SubmitInterestStatus.failure,
        errorMessage: 'Unable to save property interest.',
      ),
    ],
  );

  blocTest<SubmitInterestBloc, SubmitInterestState>(
    'reset returns the flow to its initial state',
    seed: () => const SubmitInterestState(
      status: SubmitInterestStatus.failure,
      errorMessage: 'Failed',
    ),
    build: buildBloc,
    act: (SubmitInterestBloc bloc) => bloc.add(const SubmitInterestReset()),
    expect: () => const <SubmitInterestState>[SubmitInterestState()],
  );
}
