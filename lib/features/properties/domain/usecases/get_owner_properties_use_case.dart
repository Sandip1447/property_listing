import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';

@lazySingleton
final class GetOwnerPropertiesUseCase {
  const GetOwnerPropertiesUseCase(this._repository, this._getCurrentSession);

  final PropertyRepository _repository;
  final GetCurrentSessionUseCase _getCurrentSession;

  Future<Result<List<Property>>> call() async {
    final AuthSession? session = await _getCurrentSession();
    if (session == null) {
      return const FailureResult<List<Property>>(
        AuthenticationFailure('You must be signed in as a property owner.'),
      );
    }
    if (session.role != UserRole.propertyOwner) {
      return const FailureResult<List<Property>>(
        AuthenticationFailure('Only property owners can view this dashboard.'),
      );
    }

    final Result<List<Property>> result = await _repository
        .getPropertiesByOwner(session.userId);
    return switch (result) {
      Success<List<Property>>(:final data) => Success<List<Property>>(
        List<Property>.unmodifiable(
          data.toList()..sort(
            (Property first, Property second) =>
                second.createdAt.compareTo(first.createdAt),
          ),
        ),
      ),
      FailureResult<List<Property>>(:final failure) =>
        FailureResult<List<Property>>(failure),
    };
  }
}
