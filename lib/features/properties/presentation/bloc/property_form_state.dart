import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

enum PropertyFormStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

final class PropertyFormState extends Equatable {
  const PropertyFormState({
    this.status = PropertyFormStatus.initial,
    this.property,
    this.errorMessage,
  });

  final PropertyFormStatus status;
  final Property? property;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, property, errorMessage];
}
