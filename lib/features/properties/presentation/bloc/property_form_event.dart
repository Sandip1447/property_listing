import 'package:equatable/equatable.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';

sealed class PropertyFormEvent extends Equatable {
  const PropertyFormEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PropertyFormRequested extends PropertyFormEvent {
  const PropertyFormRequested(this.propertyId);

  final String? propertyId;

  @override
  List<Object?> get props => <Object?>[propertyId];
}

final class PropertyFormSubmitted extends PropertyFormEvent {
  const PropertyFormSubmitted({required this.propertyId, required this.input});

  final String? propertyId;
  final PropertyInput input;

  @override
  List<Object?> get props => <Object?>[propertyId, input];
}
