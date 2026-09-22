import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/interests/domain/entities/interest_status.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/repositories/interest_repository.dart';

@injectable
final class UpdateInterestStatusUseCase {
  const UpdateInterestStatusUseCase(this._repository, this._getSession);

  final InterestRepository _repository;
  final GetCurrentSessionUseCase _getSession;

  Future<Result<PropertyInterest>> call({
    required String interestId,
    required InterestStatus status,
  }) async {
    final session = await _getSession();
    if (session == null || session.role != UserRole.propertyOwner) {
      return const FailureResult<PropertyInterest>(
        AuthenticationFailure('Only property owners can update enquiries.'),
      );
    }
    return _repository.updateInterestStatus(
      interestId: interestId,
      ownerId: session.userId,
      status: status,
    );
  }
}
