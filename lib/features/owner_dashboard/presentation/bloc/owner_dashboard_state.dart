import 'package:equatable/equatable.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';

enum OwnerDashboardStatus { initial, loading, success, failure }

final class OwnerDashboardState extends Equatable {
  const OwnerDashboardState({
    this.status = OwnerDashboardStatus.initial,
    this.properties = const <Property>[],
    this.interests = const <PropertyInterest>[],
    this.errorMessage,
  });

  final OwnerDashboardStatus status;
  final List<Property> properties;
  final List<PropertyInterest> interests;
  final String? errorMessage;

  int get totalProperties => properties.length;

  int get availableProperties => properties
      .where((Property property) => property.status == PropertyStatus.available)
      .length;

  int get totalInterests => interests.length;

  @override
  List<Object?> get props => <Object?>[
    status,
    properties,
    interests,
    errorMessage,
  ];
}
