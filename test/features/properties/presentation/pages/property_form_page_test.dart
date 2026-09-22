import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/add_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/update_property_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_event.dart';
import 'package:property_listing/features/properties/presentation/pages/property_form_page.dart';
import 'package:uuid/uuid.dart';

final class MockPropertyRepository extends Mock implements PropertyRepository {}

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets(
    'validates required fields and previews selected bundled images',
    (WidgetTester tester) async {
      final MockPropertyRepository propertyRepository =
          MockPropertyRepository();
      final MockAuthRepository authRepository = MockAuthRepository();
      final GetCurrentSessionUseCase getSession = GetCurrentSessionUseCase(
        authRepository,
      );
      final GetOwnedPropertyByIdUseCase getOwned = GetOwnedPropertyByIdUseCase(
        propertyRepository,
        getSession,
      );
      final PropertyFormBloc bloc = PropertyFormBloc(
        getOwned,
        AddPropertyUseCase(propertyRepository, getSession, const Uuid()),
        UpdatePropertyUseCase(propertyRepository, getOwned),
      )..add(const PropertyFormRequested(null));
      addTearDown(bloc.close);

      await tester.pumpWidget(
        BlocProvider<PropertyFormBloc>.value(
          value: bloc,
          child: const MaterialApp(home: PropertyFormPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add property'), findsOneWidget);
      expect(find.text('Property image'), findsOneWidget);
      expect(
        (tester.widget<Image>(find.byType(Image)).image as AssetImage)
            .assetName,
        'assets/images/property_placeholder.png',
      );

    await tester.tap(find.text('Apartment').first);
      await tester.pump();
      expect(
        (tester.widget<Image>(find.byType(Image)).image as AssetImage)
            .assetName,
        'assets/images/property_apartment.png',
      );

      await tester.ensureVisible(find.byKey(const Key('property_form_submit')));
      await tester.tap(find.byKey(const Key('property_form_submit')));
      await tester.pump();
      expect(find.text('Property name is required.'), findsOneWidget);
      expect(find.text('Location is required.'), findsOneWidget);
      expect(find.text('Description is required.'), findsOneWidget);
    },
  );
}
