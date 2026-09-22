import 'package:flutter/material.dart';
import 'package:property_listing/core/utils/currency_formatter.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';

class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    required this.filter,
    required this.onClear,
    super.key,
  });

  final PropertyFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final List<String> labels = <String>[
      if (filter.location != null) filter.location!,
      if (filter.propertyType != null) filter.propertyType!.label,
      if (filter.minPrice != null || filter.maxPrice != null)
        _rangeLabel(
          label: 'Price',
          minimum: filter.minPrice,
          maximum: filter.maxPrice,
          format: CurrencyFormatter.inr,
        ),
      if (filter.minArea != null || filter.maxArea != null)
        _rangeLabel(
          label: 'Area',
          minimum: filter.minArea,
          maximum: filter.maxArea,
          format: (num value) => '${value.round()} sq ft',
        ),
      if (filter.status != null) filter.status!.label,
      if (filter.bedrooms != null) '${filter.bedrooms} BHK',
    ];

    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: labels
                  .map((String label) => Chip(label: Text(label)))
                  .toList(growable: false),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }

  String _rangeLabel({
    required String label,
    required num? minimum,
    required num? maximum,
    required String Function(num value) format,
  }) {
    if (minimum != null && maximum != null) {
      return '$label: ${format(minimum)}–${format(maximum)}';
    }
    if (minimum != null) {
      return '$label: ${format(minimum)}+';
    }
    return '$label: up to ${format(maximum!)}';
  }
}
