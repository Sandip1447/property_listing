import 'package:flutter/material.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';

class PropertyStatusBadge extends StatelessWidget {
  const PropertyStatusBadge({required this.status, super.key});

  final PropertyStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (Color background, Color foreground) = switch (status) {
      PropertyStatus.available => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      PropertyStatus.sold => (colors.errorContainer, colors.onErrorContainer),
      PropertyStatus.rented => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      PropertyStatus.underConstruction => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          status.label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
