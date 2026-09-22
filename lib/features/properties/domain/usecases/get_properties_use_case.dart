import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';

@lazySingleton
final class GetPropertiesUseCase {
  const GetPropertiesUseCase(this._repository);

  final PropertyRepository _repository;

  Future<Result<List<Property>>> call() => _repository.getProperties();
}
