// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:uuid/uuid.dart' as _i706;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_session_use_case.dart'
    as _i168;
import '../../features/auth/domain/usecases/is_authenticated_use_case.dart'
    as _i811;
import '../../features/auth/domain/usecases/login_use_case.dart' as _i37;
import '../../features/auth/domain/usecases/logout_use_case.dart' as _i711;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/auth/presentation/bloc/login_bloc.dart' as _i990;
import '../../features/favourites/data/datasources/favourite_local_data_source.dart'
    as _i937;
import '../../features/favourites/data/repositories/favourite_repository_impl.dart'
    as _i848;
import '../../features/favourites/domain/repositories/favourite_repository.dart'
    as _i434;
import '../../features/favourites/domain/usecases/get_favourite_ids_use_case.dart'
    as _i897;
import '../../features/favourites/domain/usecases/toggle_favourite_use_case.dart'
    as _i738;
import '../../features/favourites/presentation/bloc/favourite_bloc.dart'
    as _i522;
import '../../features/interests/data/datasources/interest_local_data_source.dart'
    as _i662;
import '../../features/interests/data/repositories/interest_repository_impl.dart'
    as _i82;
import '../../features/interests/domain/repositories/interest_repository.dart'
    as _i1004;
import '../../features/interests/domain/usecases/get_owner_interests_use_case.dart'
    as _i795;
import '../../features/interests/domain/usecases/submit_interest_use_case.dart'
    as _i583;
import '../../features/interests/domain/usecases/update_interest_status_use_case.dart'
    as _i582;
import '../../features/interests/presentation/bloc/submit_interest_bloc.dart'
    as _i725;
import '../../features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart'
    as _i814;
import '../../features/properties/data/datasources/property_local_data_source.dart'
    as _i477;
import '../../features/properties/data/datasources/property_seed_service.dart'
    as _i818;
import '../../features/properties/data/repositories/property_repository_impl.dart'
    as _i457;
import '../../features/properties/domain/repositories/property_repository.dart'
    as _i195;
import '../../features/properties/domain/usecases/add_property_use_case.dart'
    as _i584;
import '../../features/properties/domain/usecases/delete_property_use_case.dart'
    as _i172;
import '../../features/properties/domain/usecases/filter_properties_use_case.dart'
    as _i564;
import '../../features/properties/domain/usecases/get_owned_property_by_id_use_case.dart'
    as _i258;
import '../../features/properties/domain/usecases/get_owner_properties_use_case.dart'
    as _i431;
import '../../features/properties/domain/usecases/get_properties_use_case.dart'
    as _i286;
import '../../features/properties/domain/usecases/get_property_by_id_use_case.dart'
    as _i831;
import '../../features/properties/domain/usecases/update_property_use_case.dart'
    as _i169;
import '../../features/properties/presentation/bloc/property_detail_bloc.dart'
    as _i648;
import '../../features/properties/presentation/bloc/property_form_bloc.dart'
    as _i287;
import '../../features/properties/presentation/bloc/property_list_bloc.dart'
    as _i676;
import '../storage/preferences_service.dart' as _i636;
import '../storage/secure_storage_service.dart' as _i666;
import 'modules/id_module.dart' as _i191;
import 'modules/local_storage_module.dart' as _i170;
import 'modules/network_module.dart' as _i851;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final localStorageModule = _$LocalStorageModule();
    final idModule = _$IdModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => localStorageModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i706.Uuid>(() => idModule.uuid);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => localStorageModule.secureStorage,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i564.FilterPropertiesUseCase>(
      () => const _i564.FilterPropertiesUseCase(),
    );
    gh.lazySingleton<_i636.PreferencesService>(
      () => _i636.SharedPreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i477.PropertyLocalDataSource>(
      () => _i477.SharedPreferencesPropertyLocalDataSource(
        gh<_i636.PreferencesService>(),
      ),
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.FlutterSecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i937.FavouriteLocalDataSource>(
      () => _i937.SharedPreferencesFavouriteLocalDataSource(
        gh<_i636.PreferencesService>(),
      ),
    );
    gh.lazySingleton<_i662.InterestLocalDataSource>(
      () => _i662.SharedPreferencesInterestLocalDataSource(
        gh<_i636.PreferencesService>(),
      ),
    );
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => _i852.DummyAuthLocalDataSource(
        gh<_i666.SecureStorageService>(),
        gh<_i636.PreferencesService>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.lazySingleton<_i434.FavouriteRepository>(
      () => _i848.FavouriteRepositoryImpl(gh<_i937.FavouriteLocalDataSource>()),
    );
    gh.lazySingleton<_i818.PropertySeedService>(
      () => _i818.PropertySeedService(gh<_i477.PropertyLocalDataSource>()),
    );
    gh.lazySingleton<_i1004.InterestRepository>(
      () => _i82.InterestRepositoryImpl(gh<_i662.InterestLocalDataSource>()),
    );
    gh.lazySingleton<_i195.PropertyRepository>(
      () => _i457.PropertyRepositoryImpl(gh<_i477.PropertyLocalDataSource>()),
    );
    gh.lazySingleton<_i286.GetPropertiesUseCase>(
      () => _i286.GetPropertiesUseCase(gh<_i195.PropertyRepository>()),
    );
    gh.lazySingleton<_i831.GetPropertyByIdUseCase>(
      () => _i831.GetPropertyByIdUseCase(gh<_i195.PropertyRepository>()),
    );
    gh.lazySingleton<_i897.GetFavouriteIdsUseCase>(
      () => _i897.GetFavouriteIdsUseCase(gh<_i434.FavouriteRepository>()),
    );
    gh.lazySingleton<_i738.ToggleFavouriteUseCase>(
      () => _i738.ToggleFavouriteUseCase(gh<_i434.FavouriteRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i852.AuthLocalDataSource>()),
    );
    gh.factory<_i676.PropertyListBloc>(
      () => _i676.PropertyListBloc(
        gh<_i286.GetPropertiesUseCase>(),
        gh<_i564.FilterPropertiesUseCase>(),
      ),
    );
    gh.factory<_i522.FavouriteBloc>(
      () => _i522.FavouriteBloc(
        gh<_i897.GetFavouriteIdsUseCase>(),
        gh<_i738.ToggleFavouriteUseCase>(),
        gh<_i286.GetPropertiesUseCase>(),
      ),
    );
    gh.lazySingleton<_i168.GetCurrentSessionUseCase>(
      () => _i168.GetCurrentSessionUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i811.IsAuthenticatedUseCase>(
      () => _i811.IsAuthenticatedUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i37.LoginUseCase>(
      () => _i37.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i711.LogoutUseCase>(
      () => _i711.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i990.LoginBloc>(() => _i990.LoginBloc(gh<_i37.LoginUseCase>()));
    gh.factory<_i648.PropertyDetailBloc>(
      () => _i648.PropertyDetailBloc(gh<_i831.GetPropertyByIdUseCase>()),
    );
    gh.lazySingleton<_i795.GetOwnerInterestsUseCase>(
      () => _i795.GetOwnerInterestsUseCase(
        gh<_i1004.InterestRepository>(),
        gh<_i168.GetCurrentSessionUseCase>(),
      ),
    );
    gh.factory<_i582.UpdateInterestStatusUseCase>(
      () => _i582.UpdateInterestStatusUseCase(
        gh<_i1004.InterestRepository>(),
        gh<_i168.GetCurrentSessionUseCase>(),
      ),
    );
    gh.factory<_i583.SubmitInterestUseCase>(
      () => _i583.SubmitInterestUseCase(
        gh<_i1004.InterestRepository>(),
        gh<_i831.GetPropertyByIdUseCase>(),
        gh<_i168.GetCurrentSessionUseCase>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i168.GetCurrentSessionUseCase>(),
        gh<_i711.LogoutUseCase>(),
      ),
    );
    gh.factory<_i725.SubmitInterestBloc>(
      () => _i725.SubmitInterestBloc(gh<_i583.SubmitInterestUseCase>()),
    );
    gh.lazySingleton<_i584.AddPropertyUseCase>(
      () => _i584.AddPropertyUseCase(
        gh<_i195.PropertyRepository>(),
        gh<_i168.GetCurrentSessionUseCase>(),
        gh<_i706.Uuid>(),
      ),
    );
    gh.lazySingleton<_i258.GetOwnedPropertyByIdUseCase>(
      () => _i258.GetOwnedPropertyByIdUseCase(
        gh<_i195.PropertyRepository>(),
        gh<_i168.GetCurrentSessionUseCase>(),
      ),
    );
    gh.lazySingleton<_i431.GetOwnerPropertiesUseCase>(
      () => _i431.GetOwnerPropertiesUseCase(
        gh<_i195.PropertyRepository>(),
        gh<_i168.GetCurrentSessionUseCase>(),
      ),
    );
    gh.lazySingleton<_i172.DeletePropertyUseCase>(
      () => _i172.DeletePropertyUseCase(
        gh<_i195.PropertyRepository>(),
        gh<_i258.GetOwnedPropertyByIdUseCase>(),
      ),
    );
    gh.lazySingleton<_i169.UpdatePropertyUseCase>(
      () => _i169.UpdatePropertyUseCase(
        gh<_i195.PropertyRepository>(),
        gh<_i258.GetOwnedPropertyByIdUseCase>(),
      ),
    );
    gh.factory<_i814.OwnerDashboardBloc>(
      () => _i814.OwnerDashboardBloc(
        gh<_i431.GetOwnerPropertiesUseCase>(),
        gh<_i795.GetOwnerInterestsUseCase>(),
        gh<_i172.DeletePropertyUseCase>(),
        gh<_i582.UpdateInterestStatusUseCase>(),
      ),
    );
    gh.factory<_i287.PropertyFormBloc>(
      () => _i287.PropertyFormBloc(
        gh<_i258.GetOwnedPropertyByIdUseCase>(),
        gh<_i584.AddPropertyUseCase>(),
        gh<_i169.UpdatePropertyUseCase>(),
      ),
    );
    return this;
  }
}

class _$LocalStorageModule extends _i170.LocalStorageModule {}

class _$IdModule extends _i191.IdModule {}

class _$NetworkModule extends _i851.NetworkModule {}
