import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

enum PropertyDetailStatus { initial, loading, success, failure }

final class PropertyDetailState extends Equatable {
  const PropertyDetailState({
    this.status = PropertyDetailStatus.initial,
    this.property,
    this.errorMessage,
  });

  final PropertyDetailStatus status;
  final Property? property;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, property, errorMessage];
}
