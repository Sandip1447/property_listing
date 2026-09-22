import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';

@lazySingleton
final class DeletePropertyUseCase {
  const DeletePropertyUseCase(this._repository, this._getOwnedPropertyById);

  final PropertyRepository _repository;
  final GetOwnedPropertyByIdUseCase _getOwnedPropertyById;

  Future<Result<void>> call(String propertyId) async {
    final Result<Property> existingResult = await _getOwnedPropertyById(
      propertyId,
    );
    return switch (existingResult) {
      Success<Property>() => _repository.deleteProperty(propertyId),
      FailureResult<Property>(:final failure) => FailureResult<void>(failure),
    };
  }
}
