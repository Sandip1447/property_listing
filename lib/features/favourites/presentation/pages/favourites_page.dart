import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/core/widgets/app_empty_view.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_state.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_card.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourite properties')),
      body: SafeArea(
        child: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (BuildContext context, FavouriteState state) =>
              switch (state.status) {
                FavouriteStatus.initial || FavouriteStatus.loading =>
                  const AppLoadingView(label: 'Loading favourites…'),
                FavouriteStatus.failure => AppErrorView(
                  message: state.errorMessage ?? 'Unable to load favourites.',
                  onRetry: () => context.read<FavouriteBloc>().add(
                    const FavouritesRequested(),
                  ),
                ),
                FavouriteStatus.success => _FavouriteResults(
                  properties: state.favouriteProperties,
                ),
              },
        ),
      ),
    );
  }
}

class _FavouriteResults extends StatelessWidget {
  const _FavouriteResults({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const AppEmptyView(
        icon: Icons.favorite_border,
        title: 'No favourites yet',
        message: 'Tap the heart on a property to save it here.',
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1050
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 1 ? 0.9 : 0.78,
          ),
          itemCount: properties.length,
          itemBuilder: (BuildContext context, int index) {
            final Property property = properties[index];
            return PropertyCard(
              property: property,
              isFavourite: true,
              onToggleFavourite: () => context.read<FavouriteBloc>().add(
                FavouriteToggled(property.id),
              ),
              onViewDetails: () => unawaited(
                context.pushNamed(
                  AppRoutes.userPropertyDetailName,
                  pathParameters: <String, String>{'propertyId': property.id},
                ),
              ),
            );
          },
        );
      },
    );
  }
}
