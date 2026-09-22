import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_listing/app/router/app_router.dart';
import 'package:property_listing/core/constants/app_constants.dart';
import 'package:property_listing/core/theme/app_theme.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';

class PropertyListingApp extends StatefulWidget {
  const PropertyListingApp({
    required this.authBloc,
    required this.favouriteBloc,
    required this.loginBlocFactory,
    required this.propertyListBlocFactory,
    required this.propertyDetailBlocFactory,
    required this.submitInterestBlocFactory,
    required this.ownerDashboardBlocFactory,
    required this.propertyFormBlocFactory,
    super.key,
  });

  final AuthBloc authBloc;
  final FavouriteBloc favouriteBloc;
  final LoginBlocFactory loginBlocFactory;
  final PropertyListBlocFactory propertyListBlocFactory;
  final PropertyDetailBlocFactory propertyDetailBlocFactory;
  final SubmitInterestBlocFactory submitInterestBlocFactory;
  final OwnerDashboardBlocFactory ownerDashboardBlocFactory;
  final PropertyFormBlocFactory propertyFormBlocFactory;

  @override
  State<PropertyListingApp> createState() => _PropertyListingAppState();
}

class _PropertyListingAppState extends State<PropertyListingApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      authBloc: widget.authBloc,
      loginBlocFactory: widget.loginBlocFactory,
      propertyListBlocFactory: widget.propertyListBlocFactory,
      propertyDetailBlocFactory: widget.propertyDetailBlocFactory,
      submitInterestBlocFactory: widget.submitInterestBlocFactory,
      ownerDashboardBlocFactory: widget.ownerDashboardBlocFactory,
      propertyFormBlocFactory: widget.propertyFormBlocFactory,
    );
    widget.authBloc.add(const AuthStarted());
    widget.favouriteBloc.add(const FavouritesRequested());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    unawaited(widget.authBloc.close());
    unawaited(widget.favouriteBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthBloc>.value(value: widget.authBloc),
        BlocProvider<FavouriteBloc>.value(value: widget.favouriteBloc),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.light,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
