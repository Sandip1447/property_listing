import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/app/router/go_router_refresh_stream.dart';
import 'package:property_listing/app/router/route_guards.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_bloc.dart';
import 'package:property_listing/features/auth/presentation/pages/login_page.dart';
import 'package:property_listing/features/auth/presentation/pages/splash_page.dart';
import 'package:property_listing/features/favourites/presentation/pages/favourites_page.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/interests/presentation/pages/submit_interest_page.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:property_listing/features/owner_dashboard/presentation/pages/owner_properties_page.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_event.dart';
import 'package:property_listing/features/properties/presentation/pages/property_detail_page.dart';
import 'package:property_listing/features/properties/presentation/pages/property_form_page.dart';
import 'package:property_listing/features/properties/presentation/pages/user_dashboard_page.dart';

typedef LoginBlocFactory = LoginBloc Function();
typedef PropertyListBlocFactory = PropertyListBloc Function();
typedef PropertyDetailBlocFactory = PropertyDetailBloc Function();
typedef SubmitInterestBlocFactory = SubmitInterestBloc Function();
typedef OwnerDashboardBlocFactory = OwnerDashboardBloc Function();
typedef PropertyFormBlocFactory = PropertyFormBloc Function();

final class AppRouter {
  AppRouter({
    required AuthBloc authBloc,
    required LoginBlocFactory loginBlocFactory,
    required PropertyListBlocFactory propertyListBlocFactory,
    required PropertyDetailBlocFactory propertyDetailBlocFactory,
    required SubmitInterestBlocFactory submitInterestBlocFactory,
    required OwnerDashboardBlocFactory ownerDashboardBlocFactory,
    required PropertyFormBlocFactory propertyFormBlocFactory,
  }) : _refreshListenable = GoRouterRefreshStream(authBloc.stream) {
    router = GoRouter(
      initialLocation: AppRoutes.splashPath,
      refreshListenable: _refreshListenable,
      redirect: (BuildContext context, GoRouterState state) => authRedirect(
        authState: authBloc.state,
        location: state.matchedLocation,
      ),
      routes: <RouteBase>[
        GoRoute(
          name: AppRoutes.splashName,
          path: AppRoutes.splashPath,
          builder: (BuildContext context, GoRouterState state) =>
              const SplashPage(),
        ),
        GoRoute(
          name: AppRoutes.loginName,
          path: AppRoutes.loginPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) => loginBlocFactory(),
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.userDashboardName,
          path: AppRoutes.userDashboardPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                propertyListBlocFactory()..add(const PropertyListRequested()),
            child: const UserDashboardPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.userPropertiesName,
          path: AppRoutes.userPropertiesPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                propertyListBlocFactory()..add(const PropertyListRequested()),
            child: const UserDashboardPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.userPropertyDetailName,
          path: AppRoutes.userPropertyDetailPath,
          builder: (BuildContext context, GoRouterState state) {
            final String propertyId = state.pathParameters['propertyId']!;
            return BlocProvider(
              create: (BuildContext context) =>
                  propertyDetailBlocFactory()
                    ..add(PropertyDetailRequested(propertyId)),
              child: PropertyDetailPage(propertyId: propertyId),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.submitInterestName,
          path: AppRoutes.submitInterestPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) => submitInterestBlocFactory(),
            child: SubmitInterestPage(
              propertyId: state.pathParameters['propertyId']!,
            ),
          ),
        ),
        GoRoute(
          name: AppRoutes.userFavouritesName,
          path: AppRoutes.userFavouritesPath,
          builder: (BuildContext context, GoRouterState state) =>
              const FavouritesPage(),
        ),
        GoRoute(
          name: AppRoutes.ownerDashboardName,
          path: AppRoutes.ownerDashboardPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                ownerDashboardBlocFactory()
                  ..add(const OwnerDashboardRequested()),
            child: const OwnerDashboardPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.ownerPropertiesName,
          path: AppRoutes.ownerPropertiesPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                ownerDashboardBlocFactory()
                  ..add(const OwnerDashboardRequested()),
            child: const OwnerPropertiesPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.ownerAddPropertyName,
          path: AppRoutes.ownerAddPropertyPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                propertyFormBlocFactory()
                  ..add(const PropertyFormRequested(null)),
            child: const PropertyFormPage(),
          ),
        ),
        GoRoute(
          name: AppRoutes.ownerEditPropertyName,
          path: AppRoutes.ownerEditPropertyPath,
          builder: (BuildContext context, GoRouterState state) {
            final String propertyId = state.pathParameters['propertyId']!;
            return BlocProvider(
              create: (BuildContext context) =>
                  propertyFormBlocFactory()
                    ..add(PropertyFormRequested(propertyId)),
              child: PropertyFormPage(propertyId: propertyId),
            );
          },
        ),
        GoRoute(
          name: AppRoutes.ownerInterestsName,
          path: AppRoutes.ownerInterestsPath,
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (BuildContext context) =>
                ownerDashboardBlocFactory()
                  ..add(const OwnerDashboardRequested()),
            child: const OwnerDashboardPage(),
          ),
        ),
      ],
    );
  }

  final GoRouterRefreshStream _refreshListenable;
  late final GoRouter router;

  void dispose() {
    router.dispose();
    _refreshListenable.dispose();
  }
}
