import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/auth/domain/usecases/logout_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/pages/owner_dashboard_page.dart';
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
  const AuthSession ownerSession = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  final Property property = PropertySeedData.properties.first.toEntity();
  final PropertyInterest interest = PropertyInterest(
    id: 'I001',
    propertyId: 'P001',
    propertyName: 'Green Valley Residency',
    ownerId: 'O001',
    userId: 'U001',
    fullName: 'Demo User',
    mobileNumber: '9876543210',
    email: 'user@propertydemo.com',
    message: 'Please arrange a property viewing.',
    createdAt: DateTime.utc(2026, 9, 22, 10, 30),
  );
  late MockPropertyRepository propertyRepository;
  late MockInterestRepository interestRepository;
  late MockAuthRepository authRepository;

  setUp(() {
    propertyRepository = MockPropertyRepository();
    interestRepository = MockInterestRepository();
    authRepository = MockAuthRepository();
    when(
      authRepository.getCurrentSession,
    ).thenAnswer((_) async => ownerSession);
    when(authRepository.logout).thenAnswer((_) async {});
  });

  Future<void> pumpDashboard(
    WidgetTester tester, {
    required List<Property> properties,
    required List<PropertyInterest> interests,
  }) async {
    when(
      () => propertyRepository.getPropertiesByOwner('O001'),
    ).thenAnswer((_) async => Success<List<Property>>(properties));
    when(
      () => interestRepository.getInterestsForOwner('O001'),
    ).thenAnswer((_) async => Success<List<PropertyInterest>>(interests));

    final AuthBloc authBloc = AuthBloc(
      GetCurrentSessionUseCase(authRepository),
      LogoutUseCase(authRepository),
    )..add(const AuthSessionChanged(ownerSession));
    final OwnerDashboardBloc dashboardBloc = OwnerDashboardBloc(
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
    )..add(const OwnerDashboardRequested());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<OwnerDashboardBloc>.value(value: dashboardBloc),
        ],
        child: const MaterialApp(home: OwnerDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(authBloc.close);
    addTearDown(dashboardBloc.close);
  }

  testWidgets('renders owner statistics and enquiry details', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(
      tester,
      properties: <Property>[property],
      interests: <PropertyInterest>[interest],
    );

    expect(find.text('Welcome, Demo Owner'), findsOneWidget);
    expect(find.text('Total properties'), findsOneWidget);
    expect(find.text('Available properties'), findsOneWidget);
    expect(find.text('Total interests'), findsOneWidget);
    expect(find.text('View my properties'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recent interests'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text(interest.fullName), findsOneWidget);
    expect(find.text(interest.mobileNumber), findsOneWidget);
    expect(find.text(interest.email), findsOneWidget);
    expect(find.text(interest.message), findsOneWidget);

  });

  testWidgets('renders the required empty states', (WidgetTester tester) async {
    await pumpDashboard(
      tester,
      properties: const <Property>[],
      interests: const <PropertyInterest>[],
    );

    expect(find.text('View my properties'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('No enquiries yet'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('No enquiries yet'), findsOneWidget);
    expect(
      find.text('Interest submitted for your properties will appear here.'),
      findsOneWidget,
    );
  });
}
