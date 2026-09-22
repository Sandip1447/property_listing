import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/app/app.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/auth/domain/usecases/login_use_case.dart';
import 'package:property_listing/features/auth/domain/usecases/logout_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_bloc.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';
import 'package:property_listing/features/favourites/domain/usecases/get_favourite_ids_use_case.dart';
import 'package:property_listing/features/favourites/domain/usecases/toggle_favourite_use_case.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/add_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/delete_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/filter_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/update_property_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_bloc.dart';
import 'package:uuid/uuid.dart';

final class MockAuthRepository extends Mock implements AuthRepository {}

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockInterestRepository extends Mock implements InterestRepository {}

final class MockFavouriteRepository extends Mock
    implements FavouriteRepository {}

FavouriteBloc buildFavouriteBloc(
  FavouriteRepository favouriteRepository,
  PropertyRepository propertyRepository,
) => FavouriteBloc(
  GetFavouriteIdsUseCase(favouriteRepository),
  ToggleFavouriteUseCase(favouriteRepository),
  GetPropertiesUseCase(propertyRepository),
);

OwnerDashboardBloc buildOwnerDashboardBloc(
  AuthRepository authRepository,
  PropertyRepository propertyRepository,
  InterestRepository interestRepository,
) {
  final GetCurrentSessionUseCase getSession = GetCurrentSessionUseCase(
    authRepository,
  );
  return OwnerDashboardBloc(
    GetOwnerPropertiesUseCase(propertyRepository, getSession),
    GetOwnerInterestsUseCase(interestRepository, getSession),
    DeletePropertyUseCase(
      propertyRepository,
      GetOwnedPropertyByIdUseCase(propertyRepository, getSession),
    ),
  );
}

PropertyFormBloc buildPropertyFormBloc(
  AuthRepository authRepository,
  PropertyRepository propertyRepository,
) {
  final GetCurrentSessionUseCase getSession = GetCurrentSessionUseCase(
    authRepository,
  );
  final GetOwnedPropertyByIdUseCase getOwnedProperty =
      GetOwnedPropertyByIdUseCase(propertyRepository, getSession);
  return PropertyFormBloc(
    getOwnedProperty,
    AddPropertyUseCase(propertyRepository, getSession, const Uuid()),
    UpdatePropertyUseCase(propertyRepository, getOwnedProperty),
  );
}

void main() {
  testWidgets('login form reports required fields', (
    WidgetTester tester,
  ) async {
    final MockAuthRepository repository = MockAuthRepository();
    final MockPropertyRepository propertyRepository = MockPropertyRepository();
    final MockInterestRepository interestRepository = MockInterestRepository();
    final MockFavouriteRepository favouriteRepository =
        MockFavouriteRepository();
    when(repository.getCurrentSession).thenAnswer((_) async => null);
    when(repository.logout).thenAnswer((_) async {});
    when(
      favouriteRepository.getFavouriteIds,
    ).thenAnswer((_) async => <String>{});
    when(
      propertyRepository.getProperties,
    ).thenAnswer((_) async => const Success<List<Property>>(<Property>[]));
    final AuthBloc authBloc = AuthBloc(
      GetCurrentSessionUseCase(repository),
      LogoutUseCase(repository),
    );

    await tester.pumpWidget(
      PropertyListingApp(
        authBloc: authBloc,
        favouriteBloc: buildFavouriteBloc(
          favouriteRepository,
          propertyRepository,
        ),
        loginBlocFactory: () => LoginBloc(LoginUseCase(repository)),
        propertyListBlocFactory: () => PropertyListBloc(
          GetPropertiesUseCase(propertyRepository),
          const FilterPropertiesUseCase(),
        ),
        propertyDetailBlocFactory: () =>
            PropertyDetailBloc(GetPropertyByIdUseCase(propertyRepository)),
        submitInterestBlocFactory: () => SubmitInterestBloc(
          SubmitInterestUseCase(
            interestRepository,
            GetPropertyByIdUseCase(propertyRepository),
            GetCurrentSessionUseCase(repository),
            const Uuid(),
          ),
        ),
        ownerDashboardBlocFactory: () => buildOwnerDashboardBloc(
          repository,
          propertyRepository,
          interestRepository,
        ),
        propertyFormBlocFactory: () =>
            buildPropertyFormBloc(repository, propertyRepository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back. Sign in to continue.'), findsOneWidget);
    final Finder submitButton = find.byKey(const Key('login_submit_button'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('authenticated users can search the property catalogue', (
    WidgetTester tester,
  ) async {
    const AuthSession session = AuthSession(
      userId: 'U001',
      displayName: 'Demo User',
      role: UserRole.user,
      accessToken: 'token',
    );
    final List<Property> properties = PropertySeedData.properties
        .map((PropertyModel model) => model.toEntity())
        .toList(growable: false);
    final MockAuthRepository authRepository = MockAuthRepository();
    final MockPropertyRepository propertyRepository = MockPropertyRepository();
    final MockInterestRepository interestRepository = MockInterestRepository();
    final MockFavouriteRepository favouriteRepository =
        MockFavouriteRepository();
    when(authRepository.getCurrentSession).thenAnswer((_) async => session);
    when(authRepository.logout).thenAnswer((_) async {});
    when(
      favouriteRepository.getFavouriteIds,
    ).thenAnswer((_) async => <String>{});
    when(
      propertyRepository.getProperties,
    ).thenAnswer((_) async => Success<List<Property>>(properties));
    when(
      () => propertyRepository.getPropertyById('P006'),
    ).thenAnswer((_) async => Success<Property>(properties[5]));

    await tester.pumpWidget(
      PropertyListingApp(
        authBloc: AuthBloc(
          GetCurrentSessionUseCase(authRepository),
          LogoutUseCase(authRepository),
        ),
        favouriteBloc: buildFavouriteBloc(
          favouriteRepository,
          propertyRepository,
        ),
        loginBlocFactory: () => LoginBloc(LoginUseCase(authRepository)),
        propertyListBlocFactory: () => PropertyListBloc(
          GetPropertiesUseCase(propertyRepository),
          const FilterPropertiesUseCase(),
        ),
        propertyDetailBlocFactory: () =>
            PropertyDetailBloc(GetPropertyByIdUseCase(propertyRepository)),
        submitInterestBlocFactory: () => SubmitInterestBloc(
          SubmitInterestUseCase(
            interestRepository,
            GetPropertyByIdUseCase(propertyRepository),
            GetCurrentSessionUseCase(authRepository),
            const Uuid(),
          ),
        ),
        ownerDashboardBlocFactory: () => buildOwnerDashboardBloc(
          authRepository,
          propertyRepository,
          interestRepository,
        ),
        propertyFormBlocFactory: () =>
            buildPropertyFormBloc(authRepository, propertyRepository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('10 properties'), findsOneWidget);
    expect(find.text('Green Valley Residency'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('property_search_field')),
      'Lonavala',
    );
    await tester.pump();

    expect(find.text('1 property'), findsOneWidget);
    expect(find.text('Serenity Villa'), findsOneWidget);
    verify(propertyRepository.getProperties).called(2);

    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Property details'), findsOneWidget);
    expect(find.text('Serenity Villa'), findsOneWidget);
    expect(find.text('Listed by'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('submit_interest_button')));
    await tester.tap(find.byKey(const Key('submit_interest_button')));
    await tester.pumpAndSettle();

    expect(find.text('Contact the property owner'), findsOneWidget);
    expect(find.text('Property reference: P006'), findsOneWidget);
  });

  testWidgets('authenticated owners are routed to their dashboard', (
    WidgetTester tester,
  ) async {
    const AuthSession session = AuthSession(
      userId: 'O001',
      displayName: 'Demo Owner',
      role: UserRole.propertyOwner,
      accessToken: 'token',
    );
    final List<Property> ownerProperties = PropertySeedData.properties
        .map((PropertyModel model) => model.toEntity())
        .where((Property property) => property.ownerId == session.userId)
        .toList(growable: false);
    final MockAuthRepository authRepository = MockAuthRepository();
    final MockPropertyRepository propertyRepository = MockPropertyRepository();
    final MockInterestRepository interestRepository = MockInterestRepository();
    final MockFavouriteRepository favouriteRepository =
        MockFavouriteRepository();
    when(authRepository.getCurrentSession).thenAnswer((_) async => session);
    when(authRepository.logout).thenAnswer((_) async {});
    when(
      favouriteRepository.getFavouriteIds,
    ).thenAnswer((_) async => <String>{});
    when(
      propertyRepository.getProperties,
    ).thenAnswer((_) async => const Success<List<Property>>(<Property>[]));
    when(
      () => propertyRepository.getPropertiesByOwner('O001'),
    ).thenAnswer((_) async => Success<List<Property>>(ownerProperties));
    when(
      () => interestRepository.getInterestsForOwner('O001'),
    ).thenAnswer((_) async => const Success(<PropertyInterest>[]));

    await tester.pumpWidget(
      PropertyListingApp(
        authBloc: AuthBloc(
          GetCurrentSessionUseCase(authRepository),
          LogoutUseCase(authRepository),
        ),
        favouriteBloc: buildFavouriteBloc(
          favouriteRepository,
          propertyRepository,
        ),
        loginBlocFactory: () => LoginBloc(LoginUseCase(authRepository)),
        propertyListBlocFactory: () => PropertyListBloc(
          GetPropertiesUseCase(propertyRepository),
          const FilterPropertiesUseCase(),
        ),
        propertyDetailBlocFactory: () =>
            PropertyDetailBloc(GetPropertyByIdUseCase(propertyRepository)),
        submitInterestBlocFactory: () => SubmitInterestBloc(
          SubmitInterestUseCase(
            interestRepository,
            GetPropertyByIdUseCase(propertyRepository),
            GetCurrentSessionUseCase(authRepository),
            const Uuid(),
          ),
        ),
        ownerDashboardBlocFactory: () => buildOwnerDashboardBloc(
          authRepository,
          propertyRepository,
          interestRepository,
        ),
        propertyFormBlocFactory: () =>
            buildPropertyFormBloc(authRepository, propertyRepository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Owner dashboard'), findsOneWidget);
    expect(find.text('Welcome, Demo Owner'), findsOneWidget);
    expect(find.text('Total properties'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('owner_stat_total_properties')))
          .data,
      '6',
    );
    verify(() => propertyRepository.getPropertiesByOwner('O001')).called(1);
    verify(() => interestRepository.getInterestsForOwner('O001')).called(1);
  });
}
