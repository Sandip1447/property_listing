import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';

@lazySingleton
final class GetOwnedPropertyByIdUseCase {
  const GetOwnedPropertyByIdUseCase(this._repository, this._getCurrentSession);

  final PropertyRepository _repository;
  final GetCurrentSessionUseCase _getCurrentSession;

  Future<Result<Property>> call(String propertyId) async {
    final AuthSession? session = await _getCurrentSession();
    if (session == null || session.role != UserRole.propertyOwner) {
      return const FailureResult<Property>(
        AuthenticationFailure('Only property owners can edit properties.'),
      );
    }
    final Result<Property> result = await _repository.getPropertyById(
      propertyId,
    );
    return switch (result) {
      Success<Property>(:final data) when data.ownerId == session.userId =>
        Success<Property>(data),
      Success<Property>() => const FailureResult<Property>(
        AuthenticationFailure('You can only edit your own properties.'),
      ),
      FailureResult<Property>(:final failure) => FailureResult<Property>(
        failure,
      ),
    };
  }
}
