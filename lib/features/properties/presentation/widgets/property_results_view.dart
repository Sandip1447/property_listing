import 'package:flutter/material.dart';
import 'package:property_listing/core/widgets/app_empty_view.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_state.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_card.dart';

class PropertyResultsView extends StatelessWidget {
  const PropertyResultsView({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onClearFilters,
    required this.onViewDetails,
    this.favouriteIds = const <String>{},
    this.onToggleFavourite,
    super.key,
  });

  final PropertyListState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;
  final ValueChanged<Property> onViewDetails;
  final Set<String> favouriteIds;
  final ValueChanged<Property>? onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      PropertyListStatus.initial || PropertyListStatus.loading =>
        const AppLoadingView(label: 'Loading properties…'),
      PropertyListStatus.failure => AppErrorView(
        message: state.errorMessage ?? 'Unable to load properties.',
        onRetry: onRetry,
      ),
      PropertyListStatus.success => _buildSuccess(context),
    };
  }

  Widget _buildSuccess(BuildContext context) {
    if (state.allProperties.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyView(
                icon: Icons.home_work_outlined,
                title: 'No properties available',
                message: 'New property listings will appear here.',
              ),
            ),
          ],
        ),
      );
    }
    if (state.visibleProperties.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyView(
                icon: Icons.search_off,
                title: 'No matching properties',
                message: 'Try changing your search or filters.',
                actionLabel: 'Clear filters',
                onAction: onClearFilters,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1050
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            key: const Key('property_results_grid'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 0.9 : 0.78,
            ),
            itemCount: state.visibleProperties.length,
            itemBuilder: (BuildContext context, int index) {
              final Property property = state.visibleProperties[index];
              return PropertyCard(
                property: property,
                isFavourite: favouriteIds.contains(property.id),
                onToggleFavourite: onToggleFavourite == null
                    ? null
                    : () => onToggleFavourite!(property),
                onViewDetails: () => onViewDetails(property),
              );
            },
          ),
        );
      },
    );
  }
}
