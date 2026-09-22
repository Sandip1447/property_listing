import 'package:flutter/material.dart';
import 'package:property_listing/app/app.dart';
import 'package:property_listing/core/di/injection.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_service.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_bloc.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<PropertySeedService>().seedIfRequired();
  runApp(
    PropertyListingApp(
      authBloc: getIt<AuthBloc>(),
      favouriteBloc: getIt<FavouriteBloc>(),
      loginBlocFactory: () => getIt<LoginBloc>(),
      propertyListBlocFactory: () => getIt<PropertyListBloc>(),
      propertyDetailBlocFactory: () => getIt<PropertyDetailBloc>(),
      submitInterestBlocFactory: () => getIt<SubmitInterestBloc>(),
      ownerDashboardBlocFactory: () => getIt<OwnerDashboardBloc>(),
      propertyFormBlocFactory: () => getIt<PropertyFormBloc>(),
    ),
  );
}
