import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_state.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_state.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';
import 'package:property_listing/features/properties/presentation/widgets/active_filter_chips.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_filter_sheet.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_results_view.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = context.select<AuthBloc, AuthSession?>(
      (AuthBloc bloc) => switch (bloc.state) {
        Authenticated(:final session) => session,
        _ => null,
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Find a property'),
            Text(
              'Welcome, ${session?.displayName ?? 'User'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Favourite properties',
            onPressed: () => context.pushNamed(AppRoutes.userFavouritesName),
            icon: const Icon(Icons.favorite_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PropertyListBloc, PropertyListState>(
          builder: (BuildContext context, PropertyListState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CatalogueControls(
                  searchController: _searchController,
                  state: state,
                  onFilterPressed: () => _showFilters(context, state),
                ),
                if (state.status == PropertyListStatus.success)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ActiveFilterChips(
                      filter: state.filter,
                      onClear: () => context.read<PropertyListBloc>().add(
                        const PropertyFiltersCleared(),
                      ),
                    ),
                  ),
                Expanded(
                  child: BlocBuilder<FavouriteBloc, FavouriteState>(
                    builder: (BuildContext context, FavouriteState favourite) =>
                        PropertyResultsView(
                          state: state,
                          favouriteIds: favourite.favouriteIds,
                          onToggleFavourite: (Property property) => context
                              .read<FavouriteBloc>()
                              .add(FavouriteToggled(property.id)),
                          onRefresh: () => _refresh(context),
                          onRetry: () => context.read<PropertyListBloc>().add(
                            const PropertyListRequested(),
                          ),
                          onClearFilters: () {
                            _searchController.clear();
                            context.read<PropertyListBloc>().add(
                              const PropertyFiltersChanged(PropertyFilter()),
                            );
                          },
                          onViewDetails: (Property property) {
                            unawaited(
                              context.pushNamed(
                                AppRoutes.userPropertyDetailName,
                                pathParameters: <String, String>{
                                  'propertyId': property.id,
                                },
                              ),
                            );
                          },
                        ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final PropertyListBloc bloc = context.read<PropertyListBloc>();
    bloc.add(const PropertyListRefreshed());
    await bloc.stream.firstWhere(
      (PropertyListState state) =>
          state.status == PropertyListStatus.success ||
          state.status == PropertyListStatus.failure,
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    PropertyListState state,
  ) async {
    final PropertyFilter? filter = await showPropertyFilterSheet(
      context: context,
      currentFilter: state.filter,
      properties: state.allProperties,
    );
    if (filter != null && context.mounted) {
      context.read<PropertyListBloc>().add(PropertyFiltersChanged(filter));
    }
  }
}

class _CatalogueControls extends StatelessWidget {
  const _CatalogueControls({
    required this.searchController,
    required this.state,
    required this.onFilterPressed,
  });

  final TextEditingController searchController;
  final PropertyListState state;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = state.status == PropertyListStatus.success;
    final int filterCount = _activeFilterCount(state.filter);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: const Key('property_search_field'),
            controller: searchController,
            enabled: enabled,
            textInputAction: TextInputAction.search,
            onChanged: (String query) => context.read<PropertyListBloc>().add(
              PropertySearchChanged(query),
            ),
            decoration: InputDecoration(
              hintText: 'Search by property or location',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        searchController.clear();
                        context.read<PropertyListBloc>().add(
                          const PropertySearchChanged(''),
                        );
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: enabled ? onFilterPressed : null,
                  icon: const Icon(Icons.tune),
                  label: Text(
                    filterCount == 0 ? 'Filters' : 'Filters ($filterCount)',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PopupMenuButton<PropertySort>(
                  enabled: enabled,
                  initialValue: state.filter.sort,
                  onSelected: (PropertySort sort) => context
                      .read<PropertyListBloc>()
                      .add(PropertySortChanged(sort)),
                  itemBuilder: (BuildContext context) => PropertySort.values
                      .map(
                        (PropertySort sort) => PopupMenuItem<PropertySort>(
                          value: sort,
                          child: Text(sort.label),
                        ),
                      )
                      .toList(growable: false),
                  child: IgnorePointer(
                    child: OutlinedButton.icon(
                      onPressed: enabled ? () {} : null,
                      icon: const Icon(Icons.sort),
                      label: Text(state.filter.sort?.label ?? 'Sort'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (state.status == PropertyListStatus.success) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              '${state.visibleProperties.length} '
              '${state.visibleProperties.length == 1 ? 'property' : 'properties'}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ],
      ),
    );
  }

  int _activeFilterCount(PropertyFilter filter) {
    int count = 0;
    if (filter.location != null) count++;
    if (filter.propertyType != null) count++;
    if (filter.minPrice != null || filter.maxPrice != null) count++;
    if (filter.minArea != null || filter.maxArea != null) count++;
    if (filter.status != null) count++;
    if (filter.bedrooms != null) count++;
    return count;
  }
}
