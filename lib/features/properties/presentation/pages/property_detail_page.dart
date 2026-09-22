import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/core/utils/currency_formatter.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_bloc.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_state.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_bloc.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_state.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_status_badge.dart';

class PropertyDetailPage extends StatelessWidget {
  const PropertyDetailPage({required this.propertyId, super.key});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property details')),
      body: SafeArea(
        child: BlocBuilder<PropertyDetailBloc, PropertyDetailState>(
          builder: (BuildContext context, PropertyDetailState state) =>
              switch (state.status) {
                PropertyDetailStatus.initial || PropertyDetailStatus.loading =>
                  const AppLoadingView(label: 'Loading property…'),
                PropertyDetailStatus.failure => AppErrorView(
                  message: state.errorMessage ?? 'Unable to load property.',
                  onRetry: () => context.read<PropertyDetailBloc>().add(
                    PropertyDetailRequested(propertyId),
                  ),
                ),
                PropertyDetailStatus.success =>
                  BlocBuilder<FavouriteBloc, FavouriteState>(
                    builder: (BuildContext context, FavouriteState favourite) =>
                        PropertyDetailContent(
                          property: state.property!,
                          isFavourite: favourite.isFavourite(
                            state.property!.id,
                          ),
                          onToggleFavourite: () => context
                              .read<FavouriteBloc>()
                              .add(FavouriteToggled(state.property!.id)),
                          onSubmitInterest: () => unawaited(
                            context.pushNamed(
                              AppRoutes.submitInterestName,
                              pathParameters: <String, String>{
                                'propertyId': state.property!.id,
                              },
                            ),
                          ),
                        ),
                  ),
              },
        ),
      ),
    );
  }
}

class PropertyDetailContent extends StatelessWidget {
  const PropertyDetailContent({
    required this.property,
    required this.onSubmitInterest,
    this.isFavourite = false,
    this.onToggleFavourite,
    super.key,
  });

  final Property property;
  final VoidCallback onSubmitInterest;
  final bool isFavourite;
  final VoidCallback? onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useWideLayout = constraints.maxWidth >= 900;
        final Widget image = _PropertyImage(property: property);
        final Widget details = _PropertyDetails(
          property: property,
          onSubmitInterest: onSubmitInterest,
          isFavourite: isFavourite,
          onToggleFavourite: onToggleFavourite,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: useWideLayout
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(flex: 6, child: image),
                        const SizedBox(width: 32),
                        Expanded(flex: 5, child: details),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        image,
                        const SizedBox(height: 24),
                        details,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.asset(
          property.imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stack) =>
                  ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.home_work_outlined,
                      color: colors.outline,
                      size: 72,
                    ),
                  ),
        ),
      ),
    );
  }
}

class _PropertyDetails extends StatelessWidget {
  const _PropertyDetails({
    required this.property,
    required this.onSubmitInterest,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  final Property property;
  final VoidCallback onSubmitInterest;
  final bool isFavourite;
  final VoidCallback? onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool canSubmitInterest =
        property.status == PropertyStatus.available ||
        property.status == PropertyStatus.underConstruction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            PropertyStatusBadge(status: property.status),
            const Spacer(),
            if (onToggleFavourite != null)
              IconButton.filledTonal(
                key: Key('detail_favourite_${property.id}'),
                tooltip: isFavourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? colors.error : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(property.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Icon(
              Icons.location_on_outlined,
              color: colors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(property.location),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          CurrencyFormatter.inr(property.price),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _PropertyFact(
              icon: Icons.apartment_outlined,
              label: 'Property type',
              value: property.type.label,
            ),
            _PropertyFact(
              icon: Icons.square_foot,
              label: 'Area',
              value: '${property.areaSqFt.toStringAsFixed(0)} sq ft',
            ),
            _PropertyFact(
              icon: Icons.bed_outlined,
              label: 'Bedrooms',
              value: '${property.bedrooms}',
            ),
            _PropertyFact(
              icon: Icons.bathtub_outlined,
              label: 'Bathrooms',
              value: '${property.bathrooms}',
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'About this property',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(property.description),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Listed by',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        property.ownerName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Owner reference: ${property.ownerId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('submit_interest_button'),
            onPressed: canSubmitInterest ? onSubmitInterest : null,
            icon: const Icon(Icons.send_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Submit interest'),
            ),
          ),
        ),
        if (!canSubmitInterest) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Interest submissions are unavailable for '
            '${property.status.label.toLowerCase()} properties.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _PropertyFact extends StatelessWidget {
  const _PropertyFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                  Text(value, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
