import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/interests/data/datasources/interest_local_data_source.dart';
import 'package:property_listing/features/interests/data/mappers/property_interest_mapper.dart';
import 'package:property_listing/features/interests/data/models/property_interest_model.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';

@LazySingleton(as: InterestRepository)
final class InterestRepositoryImpl implements InterestRepository {
  const InterestRepositoryImpl(this._localDataSource);

  final InterestLocalDataSource _localDataSource;

  @override
  Future<Result<PropertyInterest>> submitInterest(
    PropertyInterest interest,
  ) async {
    try {
      final PropertyInterestModel saved = await _localDataSource.addInterest(
        interest.toModel(),
      );
      return Success<PropertyInterest>(saved.toEntity());
    } on StorageException catch (error) {
      return FailureResult<PropertyInterest>(StorageFailure(error.message));
    } on Object {
      return const FailureResult<PropertyInterest>(
        UnknownFailure('Unable to submit interest.'),
      );
    }
  }

  @override
  Future<Result<List<PropertyInterest>>> getInterestsForOwner(String ownerId) =>
      _getInterests((PropertyInterestModel model) => model.ownerId == ownerId);

  @override
  Future<Result<List<PropertyInterest>>> getInterestsForProperty(
    String propertyId,
  ) => _getInterests(
    (PropertyInterestModel model) => model.propertyId == propertyId,
  );

  @override
  Future<Result<PropertyInterest>> updateInterestStatus({
    required String interestId,
    required String ownerId,
    required InterestStatus status,
  }) async {
    try {
      final List<PropertyInterestModel> interests = await _localDataSource
          .getInterests();
      final PropertyInterestModel? interest = interests
          .where((PropertyInterestModel item) =>
              item.id == interestId && item.ownerId == ownerId)
          .firstOrNull;
      if (interest == null) {
        return const FailureResult<PropertyInterest>(
          NotFoundFailure('Interest was not found for this owner.'),
        );
      }
      final PropertyInterestModel? updated = await _localDataSource
          .updateInterestStatus(interestId, status);
      if (updated == null) {
        return const FailureResult<PropertyInterest>(
          NotFoundFailure('Interest was not found.'),
        );
      }
      return Success<PropertyInterest>(updated.toEntity());
    } on StorageException catch (error) {
      return FailureResult<PropertyInterest>(StorageFailure(error.message));
    } on Object {
      return const FailureResult<PropertyInterest>(
        UnknownFailure('Unable to update interest status.'),
      );
    }
  }

  Future<Result<List<PropertyInterest>>> _getInterests(
    bool Function(PropertyInterestModel model) matches,
  ) async {
    try {
      final List<PropertyInterestModel> models = await _localDataSource
          .getInterests();
      final List<PropertyInterest> interests =
          models
              .where(matches)
              .map((PropertyInterestModel model) => model.toEntity())
              .toList()
            ..sort(
              (PropertyInterest first, PropertyInterest second) =>
                  second.createdAt.compareTo(first.createdAt),
            );
      return Success<List<PropertyInterest>>(
        List<PropertyInterest>.unmodifiable(interests),
      );
    } on StorageException catch (error) {
      return FailureResult<List<PropertyInterest>>(
        StorageFailure(error.message),
      );
    } on Object {
      return const FailureResult<List<PropertyInterest>>(
        UnknownFailure('Unable to load property interests.'),
      );
    }
  }
}
