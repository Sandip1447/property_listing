import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';

@lazySingleton
final class GetPropertyByIdUseCase {
  const GetPropertyByIdUseCase(this._repository);

  final PropertyRepository _repository;

  Future<Result<Property>> call(String id) => _repository.getPropertyById(id);
}
