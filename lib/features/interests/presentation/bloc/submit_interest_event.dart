import 'package:equatable/equatable.dart';

sealed class SubmitInterestEvent extends Equatable {
  const SubmitInterestEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class SubmitInterestSubmitted extends SubmitInterestEvent {
  const SubmitInterestSubmitted({
    required this.propertyId,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.message,
  });

  final String propertyId;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String message;

  @override
  List<Object?> get props => <Object?>[
    propertyId,
    fullName,
    mobileNumber,
    email,
    message,
  ];
}

final class SubmitInterestReset extends SubmitInterestEvent {
  const SubmitInterestReset();
}
