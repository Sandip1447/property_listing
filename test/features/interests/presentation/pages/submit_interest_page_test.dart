import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/interests/presentation/pages/submit_interest_page.dart';
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

  Future<void> pumpPage(WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/user/properties/P001/interest',
      routes: <RouteBase>[
        GoRoute(
          path: '/user/properties/:propertyId/interest',
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) => buildBloc(),
            child: SubmitInterestPage(
              propertyId: state.pathParameters['propertyId']!,
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('shows field-level validation errors', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    await tester.ensureVisible(find.byKey(const Key('interest_submit_button')));
    await tester.tap(find.byKey(const Key('interest_submit_button')));
    await tester.pump();

    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('Mobile number is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Message is required.'), findsOneWidget);
    verifyNever(() => interestRepository.submitInterest(any()));
  });

  testWidgets('submits valid values and displays the success state', (
    WidgetTester tester,
  ) async {
    when(
      () => propertyRepository.getPropertyById('P001'),
    ).thenAnswer((_) async => Success<Property>(property));
    when(authRepository.getCurrentSession).thenAnswer(
      (_) async => const AuthSession(
        userId: 'U001',
        displayName: 'Demo User',
        role: UserRole.user,
        accessToken: 'token',
      ),
    );
    when(
      () => interestRepository.submitInterest(any()),
    ).thenAnswer((_) async => Success<PropertyInterest>(savedInterest));
    await pumpPage(tester);

    await tester.enterText(
      find.byKey(const Key('interest_full_name_field')),
      'Demo User',
    );
    await tester.enterText(
      find.byKey(const Key('interest_mobile_field')),
      '9876543210',
    );
    await tester.enterText(
      find.byKey(const Key('interest_email_field')),
      'user@propertydemo.com',
    );
    await tester.enterText(
      find.byKey(const Key('interest_message_field')),
      'Please arrange a property viewing.',
    );
    await tester.ensureVisible(find.byKey(const Key('interest_submit_button')));
    await tester.tap(find.byKey(const Key('interest_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('interest_success_title')), findsOneWidget);
    expect(find.text('Interest submitted'), findsOneWidget);
    expect(find.text('Your interest has been submitted.'), findsOneWidget);
    verify(() => interestRepository.submitInterest(any())).called(1);
  });
}
