import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';

enum PropertyListStatus { initial, loading, success, failure }

final class PropertyListState extends Equatable {
  const PropertyListState({
    this.status = PropertyListStatus.initial,
    this.allProperties = const <Property>[],
    this.visibleProperties = const <Property>[],
    this.filter = const PropertyFilter(),
    this.errorMessage,
  });

  final PropertyListStatus status;
  final List<Property> allProperties;
  final List<Property> visibleProperties;
  final PropertyFilter filter;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[
    status,
    allProperties,
    visibleProperties,
    filter,
    errorMessage,
  ];
}
