import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:property_listing/core/utils/currency_formatter.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';

Future<PropertyFilter?> showPropertyFilterSheet({
  required BuildContext context,
  required PropertyFilter currentFilter,
  required List<Property> properties,
}) => showModalBottomSheet<PropertyFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (BuildContext context) =>
      PropertyFilterSheet(currentFilter: currentFilter, properties: properties),
);

class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet({
    required this.currentFilter,
    required this.properties,
    super.key,
  });

  final PropertyFilter currentFilter;
  final List<Property> properties;

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late final double _minPrice;
  late final double _maxPrice;
  late final double _minArea;
  late final double _maxArea;
  late final List<String> _locations;
  late String? _location;
  late PropertyType? _propertyType;
  late PropertyStatus? _status;
  late int? _bedrooms;
  late RangeValues _priceRange;
  late RangeValues _areaRange;

  @override
  void initState() {
    super.initState();
    final Iterable<double> prices = widget.properties.map(
      (Property item) => item.price,
    );
    final Iterable<double> areas = widget.properties.map(
      (Property item) => item.areaSqFt,
    );
    _minPrice = prices.isEmpty ? 0 : prices.reduce(math.min);
    _maxPrice = prices.isEmpty ? 1 : prices.reduce(math.max);
    _minArea = areas.isEmpty ? 0 : areas.reduce(math.min);
    _maxArea = areas.isEmpty ? 1 : areas.reduce(math.max);
    _locations =
        widget.properties
            .map((Property property) => property.location)
            .toSet()
            .toList()
          ..sort();
    _location = widget.currentFilter.location;
    _propertyType = widget.currentFilter.propertyType;
    _status = widget.currentFilter.status;
    _bedrooms = widget.currentFilter.bedrooms;
    _priceRange = RangeValues(
      (widget.currentFilter.minPrice ?? _minPrice).clamp(_minPrice, _maxPrice),
      (widget.currentFilter.maxPrice ?? _maxPrice).clamp(_minPrice, _maxPrice),
    );
    _areaRange = RangeValues(
      (widget.currentFilter.minArea ?? _minArea).clamp(_minArea, _maxArea),
      (widget.currentFilter.maxArea ?? _maxArea).clamp(_minArea, _maxArea),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController scrollController) =>
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Filter properties',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: _location,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: _locations
                          .map(
                            (String location) => DropdownMenuItem<String>(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (String? value) {
                        setState(() => _location = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Property type'),
                    Wrap(
                      spacing: 8,
                      children: PropertyType.values
                          .map(
                            (PropertyType type) => ChoiceChip(
                              label: Text(type.label),
                              selected: _propertyType == type,
                              onSelected: (bool selected) {
                                setState(() {
                                  _propertyType = selected ? type : null;
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 24),
                    _RangeHeader(
                      title: 'Price range',
                      value:
                          '${CurrencyFormatter.inr(_priceRange.start)} – '
                          '${CurrencyFormatter.inr(_priceRange.end)}',
                    ),
                    RangeSlider(
                      min: _minPrice,
                      max: _maxPrice,
                      divisions: 30,
                      values: _priceRange,
                      labels: RangeLabels(
                        CurrencyFormatter.inr(_priceRange.start),
                        CurrencyFormatter.inr(_priceRange.end),
                      ),
                      onChanged: (RangeValues value) {
                        setState(() => _priceRange = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _RangeHeader(
                      title: 'Area range',
                      value:
                          '${_areaRange.start.round()} – '
                          '${_areaRange.end.round()} sq ft',
                    ),
                    RangeSlider(
                      min: _minArea,
                      max: _maxArea,
                      divisions: 30,
                      values: _areaRange,
                      labels: RangeLabels(
                        '${_areaRange.start.round()}',
                        '${_areaRange.end.round()}',
                      ),
                      onChanged: (RangeValues value) {
                        setState(() => _areaRange = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(title: 'Status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PropertyStatus.values
                          .map(
                            (PropertyStatus status) => ChoiceChip(
                              label: Text(status.label),
                              selected: _status == status,
                              onSelected: (bool selected) {
                                setState(() {
                                  _status = selected ? status : null;
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Bedrooms'),
                    Wrap(
                      spacing: 8,
                      children: <int>[1, 2, 3, 4, 5]
                          .map(
                            (int count) => ChoiceChip(
                              label: Text('$count BHK'),
                              selected: _bedrooms == count,
                              onSelected: (bool selected) {
                                setState(() {
                                  _bedrooms = selected ? count : null;
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _apply,
                        child: const Text('Apply filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  void _apply() {
    Navigator.pop(
      context,
      PropertyFilter(
        query: widget.currentFilter.query,
        location: _location,
        propertyType: _propertyType,
        minPrice: _priceRange.start == _minPrice ? null : _priceRange.start,
        maxPrice: _priceRange.end == _maxPrice ? null : _priceRange.end,
        minArea: _areaRange.start == _minArea ? null : _areaRange.start,
        maxArea: _areaRange.end == _maxArea ? null : _areaRange.end,
        status: _status,
        bedrooms: _bedrooms,
        sort: widget.currentFilter.sort,
      ),
    );
  }

  void _reset() {
    setState(() {
      _location = null;
      _propertyType = null;
      _status = null;
      _bedrooms = null;
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _areaRange = RangeValues(_minArea, _maxArea);
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _RangeHeader extends StatelessWidget {
  const _RangeHeader({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
