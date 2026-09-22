import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/filter_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_state.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  final List<Property> properties = PropertySeedData.properties
      .map((PropertyModel model) => model.toEntity())
      .toList(growable: false);
  late MockPropertyRepository repository;

  setUp(() {
    repository = MockPropertyRepository();
  });

  PropertyListBloc buildBloc() => PropertyListBloc(
    GetPropertiesUseCase(repository),
    const FilterPropertiesUseCase(),
  );

  PropertyListState successState({
    PropertyFilter filter = const PropertyFilter(),
    List<Property>? visible,
  }) => PropertyListState(
    status: PropertyListStatus.success,
    allProperties: properties,
    visibleProperties: visible ?? properties,
    filter: filter,
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'loads all properties on request',
    setUp: () {
      when(
        repository.getProperties,
      ).thenAnswer((_) async => Success<List<Property>>(properties));
    },
    build: buildBloc,
    act: (PropertyListBloc bloc) => bloc.add(const PropertyListRequested()),
    expect: () => <Object>[
      isA<PropertyListState>().having(
        (PropertyListState state) => state.status,
        'status',
        PropertyListStatus.loading,
      ),
      isA<PropertyListState>()
          .having(
            (PropertyListState state) => state.status,
            'status',
            PropertyListStatus.success,
          )
          .having(
            (PropertyListState state) => state.visibleProperties.length,
            'visible property count',
            10,
          ),
    ],
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'emits a typed repository error message',
    setUp: () {
      when(repository.getProperties).thenAnswer(
        (_) async => const FailureResult<List<Property>>(
          StorageFailure('Property storage is unavailable.'),
        ),
      );
    },
    build: buildBloc,
    act: (PropertyListBloc bloc) => bloc.add(const PropertyListRequested()),
    expect: () => <Object>[
      isA<PropertyListState>().having(
        (PropertyListState state) => state.status,
        'status',
        PropertyListStatus.loading,
      ),
      isA<PropertyListState>()
          .having(
            (PropertyListState state) => state.status,
            'status',
            PropertyListStatus.failure,
          )
          .having(
            (PropertyListState state) => state.errorMessage,
            'error message',
            'Property storage is unavailable.',
          ),
    ],
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'searches the in-memory collection without reloading',
    seed: successState,
    build: buildBloc,
    act: (PropertyListBloc bloc) =>
        bloc.add(const PropertySearchChanged('Navi Mumbai')),
    expect: () => <Object>[
      isA<PropertyListState>()
          .having(
            (PropertyListState state) => state.filter.query,
            'query',
            'Navi Mumbai',
          )
          .having(
            (PropertyListState state) => state.visibleProperties.single.id,
            'matched property',
            'P007',
          ),
    ],
    verify: (PropertyListBloc bloc) {
      verifyNever(repository.getProperties);
    },
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'combines all filters through the filtering use case',
    seed: successState,
    build: buildBloc,
    act: (PropertyListBloc bloc) => bloc.add(
      const PropertyFiltersChanged(
        PropertyFilter(
          query: 'skyline',
          location: 'Pune',
          propertyType: PropertyType.apartment,
          minPrice: 12000000,
          maxPrice: 13000000,
          minArea: 1400,
          maxArea: 1500,
          status: PropertyStatus.underConstruction,
          bedrooms: 3,
        ),
      ),
    ),
    expect: () => <Object>[
      isA<PropertyListState>().having(
        (PropertyListState state) => state.visibleProperties.single.id,
        'matched property',
        'P009',
      ),
    ],
    verify: (PropertyListBloc bloc) {
      verifyNever(repository.getProperties);
    },
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'sorts the loaded collection without reloading',
    seed: successState,
    build: buildBloc,
    act: (PropertyListBloc bloc) =>
        bloc.add(const PropertySortChanged(PropertySort.priceHighToLow)),
    expect: () => <Object>[
      isA<PropertyListState>().having(
        (PropertyListState state) => state.visibleProperties.first.id,
        'most expensive property',
        'P006',
      ),
    ],
    verify: (PropertyListBloc bloc) {
      verifyNever(repository.getProperties);
    },
  );

  blocTest<PropertyListBloc, PropertyListState>(
    'refreshes from the repository while preserving active criteria',
    setUp: () {
      when(
        repository.getProperties,
      ).thenAnswer((_) async => Success<List<Property>>(properties));
    },
    seed: () => successState(filter: const PropertyFilter(location: 'Nashik')),
    build: buildBloc,
    act: (PropertyListBloc bloc) => bloc.add(const PropertyListRefreshed()),
    expect: () => <Object>[
      isA<PropertyListState>().having(
        (PropertyListState state) => state.status,
        'status',
        PropertyListStatus.loading,
      ),
      isA<PropertyListState>()
          .having(
            (PropertyListState state) => state.status,
            'status',
            PropertyListStatus.success,
          )
          .having(
            (PropertyListState state) => state.visibleProperties.length,
            'Nashik properties',
            2,
          ),
    ],
    verify: (PropertyListBloc bloc) {
      verify(repository.getProperties).called(1);
    },
  );
}
