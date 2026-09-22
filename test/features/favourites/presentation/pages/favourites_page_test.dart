import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/favourites/domain/repositories/favourite_repository.dart';
import 'package:property_listing/features/favourites/domain/usecases/get_favourite_ids_use_case.dart';
import 'package:property_listing/features/favourites/domain/usecases/toggle_favourite_use_case.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/pages/favourites_page.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';

final class MockFavouriteRepository extends Mock
    implements FavouriteRepository {}

final class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  testWidgets('shows saved properties and removes favourites', (
    WidgetTester tester,
  ) async {
    final Property property = PropertySeedData.properties.first.toEntity();
    final MockFavouriteRepository favouriteRepository =
        MockFavouriteRepository();
    final MockPropertyRepository propertyRepository = MockPropertyRepository();
    final Set<String> ids = <String>{property.id};
    when(
      favouriteRepository.getFavouriteIds,
    ).thenAnswer((_) async => Set<String>.of(ids));
    when(() => favouriteRepository.removeFavourite(property.id)).thenAnswer((
      _,
    ) async {
      ids.remove(property.id);
    });
    when(
      propertyRepository.getProperties,
    ).thenAnswer((_) async => Success<List<Property>>(<Property>[property]));
    final FavouriteBloc bloc = FavouriteBloc(
      GetFavouriteIdsUseCase(favouriteRepository),
      ToggleFavouriteUseCase(favouriteRepository),
      GetPropertiesUseCase(propertyRepository),
    )..add(const FavouritesRequested());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<FavouriteBloc>.value(
        value: bloc,
        child: const MaterialApp(home: FavouritesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(property.name), findsOneWidget);
    expect(find.byKey(Key('favourite_${property.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('favourite_${property.id}')));
    await tester.pumpAndSettle();

    expect(find.text('No favourites yet'), findsOneWidget);
    verify(() => favouriteRepository.removeFavourite(property.id)).called(1);
  });
}
