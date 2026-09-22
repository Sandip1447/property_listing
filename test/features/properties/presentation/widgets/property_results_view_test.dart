import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/properties/data/datasources/property_seed_data.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_state.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_results_view.dart';

void main() {
  Widget buildView(PropertyListState state) => MaterialApp(
    home: Scaffold(
      body: PropertyResultsView(
        state: state,
        onRefresh: () async {},
        onRetry: () {},
        onClearFilters: () {},
        onViewDetails: (_) {},
      ),
    ),
  );

  testWidgets('renders the unfiltered empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildView(const PropertyListState(status: PropertyListStatus.success)),
    );

    expect(find.text('No properties available'), findsOneWidget);
  });

  testWidgets('renders the filtered-empty state with a clear action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildView(
        PropertyListState(
          status: PropertyListStatus.success,
          allProperties: <Property>[
            PropertySeedData.properties.first.toEntity(),
          ],
          filter: const PropertyFilter(location: 'Nowhere'),
        ),
      ),
    );

    expect(find.text('No matching properties'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });
}
