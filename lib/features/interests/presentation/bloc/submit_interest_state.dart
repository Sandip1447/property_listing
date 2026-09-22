import 'package:equatable/equatable.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';

enum SubmitInterestStatus { initial, submitting, success, failure }

final class SubmitInterestState extends Equatable {
  const SubmitInterestState({
    this.status = SubmitInterestStatus.initial,
    this.interest,
    this.errorMessage,
  });

  final SubmitInterestStatus status;
  final PropertyInterest? interest;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, interest, errorMessage];
}
