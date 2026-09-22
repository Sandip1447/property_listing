import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/property_input_validator.dart';

@lazySingleton
final class UpdatePropertyUseCase {
  const UpdatePropertyUseCase(this._repository, this._getOwnedPropertyById);

  final PropertyRepository _repository;
  final GetOwnedPropertyByIdUseCase _getOwnedPropertyById;

  Future<Result<Property>> call({
    required String propertyId,
    required PropertyInput input,
  }) async {
    final String? validationMessage = PropertyInputValidator.validate(input);
    if (validationMessage != null) {
      return FailureResult<Property>(ValidationFailure(validationMessage));
    }
    final Result<Property> existingResult = await _getOwnedPropertyById(
      propertyId,
    );
    switch (existingResult) {
      case FailureResult<Property>(:final failure):
        return FailureResult<Property>(failure);
      case Success<Property>(data: final existing):
        return _repository.updateProperty(
          Property(
            id: existing.id,
            ownerId: existing.ownerId,
            ownerName: existing.ownerName,
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
            createdAt: existing.createdAt,
          ),
        );
    }
  }
}
