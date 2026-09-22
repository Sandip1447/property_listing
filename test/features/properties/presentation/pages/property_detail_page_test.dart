import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/presentation/pages/property_detail_page.dart';

void main() {
  testWidgets('renders all property details and submits available interest', (
    WidgetTester tester,
  ) async {
    final Property property = PropertySeedData.properties.first.toEntity();
    bool submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyDetailContent(
            property: property,
            onSubmitInterest: () => submitted = true,
          ),
        ),
      ),
    );

    expect(find.text(property.name), findsOneWidget);
    expect(find.text(property.location), findsOneWidget);
    expect(find.text(property.description), findsOneWidget);
    expect(find.text(property.ownerName), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));

    final Finder button = find.byKey(const Key('submit_interest_button'));
    await tester.ensureVisible(button);
    await tester.tap(button);

    expect(submitted, isTrue);
  });

  testWidgets('disables interest submission for rented properties', (
    WidgetTester tester,
  ) async {
    final Property source = PropertySeedData.properties.first.toEntity();
    final Property rented = Property(
      id: source.id,
      ownerId: source.ownerId,
      ownerName: source.ownerName,
      name: source.name,
      type: source.type,
      location: source.location,
      price: source.price,
      areaSqFt: source.areaSqFt,
      bedrooms: source.bedrooms,
      bathrooms: source.bathrooms,
      status: PropertyStatus.rented,
      description: source.description,
      imageUrl: source.imageUrl,
      createdAt: source.createdAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PropertyDetailContent(
            property: rented,
            onSubmitInterest: () {},
          ),
        ),
      ),
    );

    final FilledButton button = tester.widget<FilledButton>(
      find.byKey(const Key('submit_interest_button')),
    );
    expect(button.onPressed, isNull);
    expect(
      find.text('Interest submissions are unavailable for rented properties.'),
      findsOneWidget,
    );
  });
}
