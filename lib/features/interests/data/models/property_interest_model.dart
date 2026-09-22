import 'package:property_listing/features/interests/domain/entities/interest_status.dart';

final class PropertyInterestModel {
  const PropertyInterestModel({
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

  factory PropertyInterestModel.fromJson(Map<String, Object?> json) =>
      PropertyInterestModel(
        id: _readString(json, 'id'),
        propertyId: _readString(json, 'propertyId'),
        propertyName: _readString(json, 'propertyName'),
        ownerId: _readString(json, 'ownerId'),
        userId: _readString(json, 'userId'),
        fullName: _readString(json, 'fullName'),
        mobileNumber: _readString(json, 'mobileNumber'),
        email: _readString(json, 'email'),
        message: _readString(json, 'message'),
        createdAt: DateTime.parse(_readString(json, 'createdAt')),
        status: _readStatus(json['status']),
      );

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

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'propertyId': propertyId,
    'propertyName': propertyName,
    'ownerId': ownerId,
    'userId': userId,
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    'email': email,
    'message': message,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'status': status.name,
  };
}

InterestStatus _readStatus(Object? value) => switch (value) {
  'contacted' => InterestStatus.contacted,
  'interested' => InterestStatus.interested,
  'closed' => InterestStatus.closed,
  _ => InterestStatus.newRequest,
};

String _readString(Map<String, Object?> json, String key) {
  final Object? value = json[key];
  if (value is String) {
    return value;
  }
  throw FormatException('Expected a string for "$key".');
}
