import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';
import 'package:property_listing/features/favourites/domain/usecases/get_favourite_ids_use_case.dart';
import 'package:property_listing/features/favourites/domain/usecases/toggle_favourite_use_case.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_state.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';

final class MockFavouriteRepository extends Mock
    implements FavouriteRepository {}

final class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  final List<Property> properties = <Property>[
    PropertySeedData.properties.first.toEntity(),
  ];
  late MockFavouriteRepository favouriteRepository;
  late MockPropertyRepository propertyRepository;
  late Set<String> storedIds;

  setUp(() {
    favouriteRepository = MockFavouriteRepository();
    propertyRepository = MockPropertyRepository();
    storedIds = <String>{};
    when(
      favouriteRepository.getFavouriteIds,
    ).thenAnswer((_) async => Set<String>.of(storedIds));
    when(() => favouriteRepository.addFavourite(any())).thenAnswer((
      invocation,
    ) async {
      storedIds.add(invocation.positionalArguments.single as String);
    });
    when(() => favouriteRepository.removeFavourite(any())).thenAnswer((
      invocation,
    ) async {
      storedIds.remove(invocation.positionalArguments.single as String);
    });
    when(
      propertyRepository.getProperties,
    ).thenAnswer((_) async => Success<List<Property>>(properties));
  });

  FavouriteBloc buildBloc() => FavouriteBloc(
    GetFavouriteIdsUseCase(favouriteRepository),
    ToggleFavouriteUseCase(favouriteRepository),
    GetPropertiesUseCase(propertyRepository),
  );

  blocTest<FavouriteBloc, FavouriteState>(
    'loads favourites and their property records',
    setUp: () => storedIds.add('P001'),
    build: buildBloc,
    act: (FavouriteBloc bloc) => bloc.add(const FavouritesRequested()),
    expect: () => <FavouriteState>[
      const FavouriteState(status: FavouriteStatus.loading),
      FavouriteState(
        status: FavouriteStatus.success,
        favouriteIds: const <String>{'P001'},
        properties: properties,
      ),
    ],
    verify: (FavouriteBloc bloc) {
      expect(bloc.state.favouriteProperties.single.id, 'P001');
    },
  );

  blocTest<FavouriteBloc, FavouriteState>(
    'toggles and persists a favourite ID',
    seed: () =>
        FavouriteState(status: FavouriteStatus.success, properties: properties),
    build: buildBloc,
    act: (FavouriteBloc bloc) => bloc.add(const FavouriteToggled('P001')),
    expect: () => <FavouriteState>[
      FavouriteState(
        status: FavouriteStatus.success,
        favouriteIds: const <String>{'P001'},
        properties: properties,
      ),
    ],
    verify: (FavouriteBloc bloc) {
      verify(() => favouriteRepository.addFavourite('P001')).called(1);
    },
  );
}
