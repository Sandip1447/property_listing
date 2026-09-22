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
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_state.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/delete_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockInterestRepository extends Mock implements InterestRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession session = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  final List<Property> properties = <Property>[
    PropertySeedData.properties.first.toEntity(),
  ];
  final List<PropertyInterest> interests = <PropertyInterest>[
    PropertyInterest(
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
    ),
  ];
  late MockPropertyRepository propertyRepository;
  late MockInterestRepository interestRepository;
  late MockAuthRepository authRepository;

  setUp(() {
    propertyRepository = MockPropertyRepository();
    interestRepository = MockInterestRepository();
    authRepository = MockAuthRepository();
    when(authRepository.getCurrentSession).thenAnswer((_) async => session);
  });

  OwnerDashboardBloc buildBloc() => OwnerDashboardBloc(
    GetOwnerPropertiesUseCase(
      propertyRepository,
      GetCurrentSessionUseCase(authRepository),
    ),
    GetOwnerInterestsUseCase(
      interestRepository,
      GetCurrentSessionUseCase(authRepository),
    ),
    DeletePropertyUseCase(
      propertyRepository,
      GetOwnedPropertyByIdUseCase(
        propertyRepository,
        GetCurrentSessionUseCase(authRepository),
      ),
    ),
  );

  blocTest<OwnerDashboardBloc, OwnerDashboardState>(
    'loads owner properties and interests',
    setUp: () {
      when(
        () => propertyRepository.getPropertiesByOwner('O001'),
      ).thenAnswer((_) async => Success<List<Property>>(properties));
      when(
        () => interestRepository.getInterestsForOwner('O001'),
      ).thenAnswer((_) async => Success<List<PropertyInterest>>(interests));
    },
    build: buildBloc,
    act: (OwnerDashboardBloc bloc) => bloc.add(const OwnerDashboardRequested()),
    expect: () => <OwnerDashboardState>[
      const OwnerDashboardState(status: OwnerDashboardStatus.loading),
      OwnerDashboardState(
        status: OwnerDashboardStatus.success,
        properties: properties,
        interests: interests,
      ),
    ],
  );

  blocTest<OwnerDashboardBloc, OwnerDashboardState>(
    'stops and reports a property-loading failure',
    setUp: () {
      when(() => propertyRepository.getPropertiesByOwner('O001')).thenAnswer(
        (_) async => const FailureResult<List<Property>>(
          StorageFailure('Unable to load owner properties.'),
        ),
      );
    },
    build: buildBloc,
    act: (OwnerDashboardBloc bloc) => bloc.add(const OwnerDashboardRequested()),
    expect: () => const <OwnerDashboardState>[
      OwnerDashboardState(status: OwnerDashboardStatus.loading),
      OwnerDashboardState(
        status: OwnerDashboardStatus.failure,
        errorMessage: 'Unable to load owner properties.',
      ),
    ],
    verify: (OwnerDashboardBloc bloc) {
      verifyNever(() => interestRepository.getInterestsForOwner(any()));
    },
  );

  blocTest<OwnerDashboardBloc, OwnerDashboardState>(
    'reports an interest-loading failure while retaining properties',
    setUp: () {
      when(
        () => propertyRepository.getPropertiesByOwner('O001'),
      ).thenAnswer((_) async => Success<List<Property>>(properties));
      when(() => interestRepository.getInterestsForOwner('O001')).thenAnswer(
        (_) async => const FailureResult<List<PropertyInterest>>(
          StorageFailure('Unable to load owner interests.'),
        ),
      );
    },
    build: buildBloc,
    act: (OwnerDashboardBloc bloc) => bloc.add(const OwnerDashboardRefreshed()),
    expect: () => <OwnerDashboardState>[
      const OwnerDashboardState(status: OwnerDashboardStatus.loading),
      OwnerDashboardState(
        status: OwnerDashboardStatus.failure,
        properties: properties,
        errorMessage: 'Unable to load owner interests.',
      ),
    ],
  );

  test('computes dashboard statistics from loaded data', () {
    final OwnerDashboardState state = OwnerDashboardState(
      status: OwnerDashboardStatus.success,
      properties: properties,
      interests: interests,
    );

    expect(state.totalProperties, 1);
    expect(state.availableProperties, 1);
    expect(state.totalInterests, 1);
  });
}
