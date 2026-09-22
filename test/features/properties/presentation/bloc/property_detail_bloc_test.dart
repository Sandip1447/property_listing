import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_state.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  final Property property = PropertySeedData.properties.first.toEntity();
  late MockPropertyRepository repository;

  setUp(() {
    repository = MockPropertyRepository();
  });

  PropertyDetailBloc buildBloc() =>
      PropertyDetailBloc(GetPropertyByIdUseCase(repository));

  blocTest<PropertyDetailBloc, PropertyDetailState>(
    'loads a property by ID',
    setUp: () {
      when(
        () => repository.getPropertyById('P001'),
      ).thenAnswer((_) async => Success<Property>(property));
    },
    build: buildBloc,
    act: (PropertyDetailBloc bloc) =>
        bloc.add(const PropertyDetailRequested('P001')),
    expect: () => <PropertyDetailState>[
      const PropertyDetailState(status: PropertyDetailStatus.loading),
      PropertyDetailState(
        status: PropertyDetailStatus.success,
        property: property,
      ),
    ],
    verify: (PropertyDetailBloc bloc) {
      verify(() => repository.getPropertyById('P001')).called(1);
    },
  );

  blocTest<PropertyDetailBloc, PropertyDetailState>(
    'surfaces a missing-property failure',
    setUp: () {
      when(() => repository.getPropertyById('P999')).thenAnswer(
        (_) async => const FailureResult<Property>(
          NotFoundFailure('Property "P999" was not found.'),
        ),
      );
    },
    build: buildBloc,
    act: (PropertyDetailBloc bloc) =>
        bloc.add(const PropertyDetailRequested('P999')),
    expect: () => const <PropertyDetailState>[
      PropertyDetailState(status: PropertyDetailStatus.loading),
      PropertyDetailState(
        status: PropertyDetailStatus.failure,
        errorMessage: 'Property "P999" was not found.',
      ),
    ],
  );

  blocTest<PropertyDetailBloc, PropertyDetailState>(
    'surfaces repository storage failures',
    setUp: () {
      when(() => repository.getPropertyById('P001')).thenAnswer(
        (_) async => const FailureResult<Property>(
          StorageFailure('Unable to read property storage.'),
        ),
      );
    },
    build: buildBloc,
    act: (PropertyDetailBloc bloc) =>
        bloc.add(const PropertyDetailRequested('P001')),
    expect: () => const <PropertyDetailState>[
      PropertyDetailState(status: PropertyDetailStatus.loading),
      PropertyDetailState(
        status: PropertyDetailStatus.failure,
        errorMessage: 'Unable to read property storage.',
      ),
    ],
  );
}
