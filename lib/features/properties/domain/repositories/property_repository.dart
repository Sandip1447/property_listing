import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

abstract interface class PropertyRepository {
  Future<Result<List<Property>>> getProperties();

  Future<Result<Property>> getPropertyById(String id);

  Future<Result<List<Property>>> getPropertiesByOwner(String ownerId);

  Future<Result<Property>> addProperty(Property property);

  Future<Result<Property>> updateProperty(Property property);

  Future<Result<void>> deleteProperty(String id);
}
