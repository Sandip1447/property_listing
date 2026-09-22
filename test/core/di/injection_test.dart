import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/core/di/injection.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/core/storage/secure_storage_service.dart';
import 'package:property_listing/features/favourites/data/datasources/favourite_local_data_source.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/interests/data/datasources/interest_local_data_source.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_service.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/add_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/delete_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/filter_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/update_property_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('registers application infrastructure dependencies', () async {
    await configureDependencies();

    expect(getIt<PreferencesService>(), isA<SharedPreferencesService>());
    expect(getIt<SecureStorageService>(), isA<FlutterSecureStorageService>());
    expect(getIt<FlutterSecureStorage>(), isA<FlutterSecureStorage>());
    expect(getIt<Dio>(), isA<Dio>());
    expect(getIt<PropertyLocalDataSource>(), isA<PropertyLocalDataSource>());
    expect(getIt<PropertyRepository>(), isA<PropertyRepository>());
    expect(getIt<PropertySeedService>(), isA<PropertySeedService>());
    expect(getIt<GetPropertiesUseCase>(), isA<GetPropertiesUseCase>());
    expect(getIt<FilterPropertiesUseCase>(), isA<FilterPropertiesUseCase>());
    expect(getIt<InterestLocalDataSource>(), isA<InterestLocalDataSource>());
    expect(getIt<InterestRepository>(), isA<InterestRepository>());
    expect(getIt<SubmitInterestUseCase>(), isA<SubmitInterestUseCase>());
    expect(getIt<SubmitInterestBloc>(), isA<SubmitInterestBloc>());
    expect(
      getIt<GetOwnerPropertiesUseCase>(),
      isA<GetOwnerPropertiesUseCase>(),
    );
    expect(getIt<GetOwnerInterestsUseCase>(), isA<GetOwnerInterestsUseCase>());
    expect(getIt<OwnerDashboardBloc>(), isA<OwnerDashboardBloc>());
    expect(getIt<FavouriteLocalDataSource>(), isA<FavouriteLocalDataSource>());
    expect(getIt<FavouriteRepository>(), isA<FavouriteRepository>());
    expect(getIt<FavouriteBloc>(), isA<FavouriteBloc>());
    expect(getIt<AddPropertyUseCase>(), isA<AddPropertyUseCase>());
    expect(getIt<UpdatePropertyUseCase>(), isA<UpdatePropertyUseCase>());
    expect(getIt<DeletePropertyUseCase>(), isA<DeletePropertyUseCase>());
    expect(getIt<PropertyFormBloc>(), isA<PropertyFormBloc>());
  });
}
