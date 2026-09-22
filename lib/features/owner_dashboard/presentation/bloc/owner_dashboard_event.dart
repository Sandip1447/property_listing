import 'package:equatable/equatable.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';

sealed class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class OwnerDashboardRequested extends OwnerDashboardEvent {
  const OwnerDashboardRequested();
}

final class OwnerDashboardRefreshed extends OwnerDashboardEvent {
  const OwnerDashboardRefreshed();
}

final class OwnerPropertyDeleteRequested extends OwnerDashboardEvent {
  const OwnerPropertyDeleteRequested(this.propertyId);

  final String propertyId;

  @override
  List<Object?> get props => <Object?>[propertyId];
}

final class OwnerInterestStatusChanged extends OwnerDashboardEvent {
  const OwnerInterestStatusChanged({
    required this.interestId,
    required this.status,
  });

  final String interestId;
  final InterestStatus status;

  @override
  List<Object?> get props => <Object?>[interestId, status];
}
