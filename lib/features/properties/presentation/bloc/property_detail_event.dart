import 'package:equatable/equatable.dart';

sealed class PropertyDetailEvent extends Equatable {
  const PropertyDetailEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PropertyDetailRequested extends PropertyDetailEvent {
  const PropertyDetailRequested(this.propertyId);

  final String propertyId;

  @override
  List<Object?> get props => <Object?>[propertyId];
}
