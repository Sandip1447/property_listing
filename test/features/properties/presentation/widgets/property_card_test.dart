import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_card.dart';

void main() {
  testWidgets('renders key property information and details action', (
    WidgetTester tester,
  ) async {
    final Property property = PropertySeedData.properties.first.toEntity();
    bool detailsTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: PropertyCard(
                property: property,
                onViewDetails: () => detailsTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Green Valley Residency'), findsOneWidget);
    expect(find.text('Pune'), findsOneWidget);
    expect(find.text('Apartment'), findsOneWidget);
    expect(find.text('2 BHK'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);

    await tester.tap(find.text('View details'));
    expect(detailsTapped, isTrue);
  });
}
