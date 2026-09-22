import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';

@lazySingleton
final class GetOwnerInterestsUseCase {
  const GetOwnerInterestsUseCase(this._repository, this._getCurrentSession);

  final InterestRepository _repository;
  final GetCurrentSessionUseCase _getCurrentSession;

  Future<Result<List<PropertyInterest>>> call() async {
    final AuthSession? session = await _getCurrentSession();
    if (session == null) {
      return const FailureResult<List<PropertyInterest>>(
        AuthenticationFailure('You must be signed in as a property owner.'),
      );
    }
    if (session.role != UserRole.propertyOwner) {
      return const FailureResult<List<PropertyInterest>>(
        AuthenticationFailure('Only property owners can view enquiries.'),
      );
    }

    final Result<List<PropertyInterest>> result = await _repository
        .getInterestsForOwner(session.userId);
    return switch (result) {
      Success<List<PropertyInterest>>(:final data) =>
        Success<List<PropertyInterest>>(
          List<PropertyInterest>.unmodifiable(
            data.toList()..sort(
              (PropertyInterest first, PropertyInterest second) =>
                  second.createdAt.compareTo(first.createdAt),
            ),
          ),
        ),
      FailureResult<List<PropertyInterest>>(:final failure) =>
        FailureResult<List<PropertyInterest>>(failure),
    };
  }
}
