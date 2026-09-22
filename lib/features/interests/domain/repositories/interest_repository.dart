import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';

abstract interface class InterestRepository {
  Future<Result<PropertyInterest>> submitInterest(PropertyInterest interest);

  Future<Result<List<PropertyInterest>>> getInterestsForOwner(String ownerId);

  Future<Result<List<PropertyInterest>>> getInterestsForProperty(
    String propertyId,
  );

  Future<Result<PropertyInterest>> updateInterestStatus({
    required String interestId,
    required String ownerId,
    required InterestStatus status,
  });
}
