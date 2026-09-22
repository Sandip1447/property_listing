import 'package:equatable/equatable.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';

final class PropertyInterest extends Equatable {
  const PropertyInterest({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    required this.userId,
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    required this.message,
    required this.createdAt,
    this.status = InterestStatus.newRequest,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String ownerId;
  final String userId;
  final String fullName;
  final String mobileNumber;
  final String email;
  final String message;
  final DateTime createdAt;
  final InterestStatus status;

  @override
  List<Object?> get props => <Object?>[
    id,
    propertyId,
    propertyName,
    ownerId,
    userId,
    fullName,
    mobileNumber,
    email,
    message,
    createdAt,
    status,
  ];
}
