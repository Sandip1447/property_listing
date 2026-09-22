import 'package:flutter/material.dart';
import 'package:property_listing/core/utils/currency_formatter.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';
import 'package:property_listing/features/properties/presentation/widgets/property_status_badge.dart';

class OwnerPropertyCard extends StatelessWidget {
  const OwnerPropertyCard({
    required this.property,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Property property;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    property.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                PropertyStatusBadge(status: property.status),
              ],
            ),
            const SizedBox(height: 12),
            _PropertyLine(
              icon: Icons.location_on_outlined,
              text: property.location,
            ),
            const SizedBox(height: 8),
            _PropertyLine(
              icon: Icons.home_work_outlined,
              text: '${property.type.label} • ${property.bedrooms} BHK',
            ),
            const SizedBox(height: 8),
            _PropertyLine(
              icon: Icons.square_foot,
              text: '${property.areaSqFt.toStringAsFixed(0)} sq ft',
            ),
            const Spacer(),
            Text(
              CurrencyFormatter.inr(property.price),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  key: Key('delete_${property.id}'),
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colors.error,
                  ),
                  label: Text('Delete', style: TextStyle(color: colors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyLine extends StatelessWidget {
  const _PropertyLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
