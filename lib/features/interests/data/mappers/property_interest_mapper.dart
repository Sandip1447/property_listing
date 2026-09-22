import 'package:property_listing/features/interests/data/models/property_interest_model.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';

extension PropertyInterestModelMapper on PropertyInterestModel {
  PropertyInterest toEntity() => PropertyInterest(
    id: id,
    propertyId: propertyId,
    propertyName: propertyName,
    ownerId: ownerId,
    userId: userId,
    fullName: fullName,
    mobileNumber: mobileNumber,
    email: email,
    message: message,
    createdAt: createdAt,
    status: status,
  );
}

extension PropertyInterestEntityMapper on PropertyInterest {
  PropertyInterestModel toModel() => PropertyInterestModel(
    id: id,
    propertyId: propertyId,
    propertyName: propertyName,
    ownerId: ownerId,
    userId: userId,
    fullName: fullName,
    mobileNumber: mobileNumber,
    email: email,
    message: message,
    createdAt: createdAt,
    status: status,
  );
}
