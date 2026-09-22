import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/property_input_validator.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
final class AddPropertyUseCase {
  const AddPropertyUseCase(
    this._repository,
    this._getCurrentSession,
    this._uuid,
  );

  final PropertyRepository _repository;
  final GetCurrentSessionUseCase _getCurrentSession;
  final Uuid _uuid;

  Future<Result<Property>> call(PropertyInput input) async {
    final String? validationMessage = PropertyInputValidator.validate(input);
    if (validationMessage != null) {
      return FailureResult<Property>(ValidationFailure(validationMessage));
    }
    final AuthSession? session = await _getCurrentSession();
    if (session == null || session.role != UserRole.propertyOwner) {
      return const FailureResult<Property>(
        AuthenticationFailure('Only property owners can add properties.'),
      );
    }

    return _repository.addProperty(
      Property(
        id: _uuid.v4(),
        ownerId: session.userId,
        ownerName: session.displayName,
        name: input.name.trim(),
        type: input.type,
        location: input.location.trim(),
        price: input.price,
        areaSqFt: input.areaSqFt,
        bedrooms: input.bedrooms,
        bathrooms: input.bathrooms,
        status: input.status,
        description: input.description.trim(),
        imageUrl: input.imageUrl,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}
