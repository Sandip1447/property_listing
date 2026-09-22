import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/data/datasources/property_local_data_source.dart';
import 'package:property_listing/features/properties/data/mappers/property_mapper.dart';
import 'package:property_listing/features/properties/data/models/property_model.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/repositories/property_repository.dart';

@LazySingleton(as: PropertyRepository)
final class PropertyRepositoryImpl implements PropertyRepository {
  const PropertyRepositoryImpl(this._localDataSource);

  final PropertyLocalDataSource _localDataSource;

  @override
  Future<Result<List<Property>>> getProperties() async {
    try {
      final List<PropertyModel> models = await _localDataSource.getProperties();
      return Success<List<Property>>(
        List<Property>.unmodifiable(
          models.map((PropertyModel model) => model.toEntity()),
        ),
      );
    } on StorageException catch (error) {
      return FailureResult<List<Property>>(StorageFailure(error.message));
    } on Object {
      return const FailureResult<List<Property>>(
        UnknownFailure('Unable to load properties.'),
      );
    }
  }

  @override
  Future<Result<Property>> getPropertyById(String id) async {
    final Result<List<Property>> result = await getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        for (final Property property in data) {
          if (property.id == id) {
            return Success<Property>(property);
          }
        }
        return FailureResult<Property>(
          NotFoundFailure('Property "$id" was not found.'),
        );
      case FailureResult<List<Property>>(:final failure):
        return FailureResult<Property>(failure);
    }
  }

  @override
  Future<Result<List<Property>>> getPropertiesByOwner(String ownerId) async {
    final Result<List<Property>> result = await getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        return Success<List<Property>>(
          List<Property>.unmodifiable(
            data.where((Property property) => property.ownerId == ownerId),
          ),
        );
      case FailureResult<List<Property>>(:final failure):
        return FailureResult<List<Property>>(failure);
    }
  }

  @override
  Future<Result<Property>> addProperty(Property property) async {
    final Result<List<Property>> result = await getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        if (data.any((Property item) => item.id == property.id)) {
          return const FailureResult<Property>(
            ValidationFailure('A property with this ID already exists.'),
          );
        }
        try {
          await _localDataSource.saveProperties(<PropertyModel>[
            ...data.map((Property item) => item.toModel()),
            property.toModel(),
          ]);
          return Success<Property>(property);
        } on StorageException catch (error) {
          return FailureResult<Property>(StorageFailure(error.message));
        } on Object {
          return const FailureResult<Property>(
            UnknownFailure('Unable to add property.'),
          );
        }
      case FailureResult<List<Property>>(:final failure):
        return FailureResult<Property>(failure);
    }
  }

  @override
  Future<Result<Property>> updateProperty(Property property) async {
    final Result<List<Property>> result = await getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        final int index = data.indexWhere(
          (Property item) => item.id == property.id,
        );
        if (index == -1) {
          return FailureResult<Property>(
            NotFoundFailure('Property "${property.id}" was not found.'),
          );
        }
        final List<PropertyModel> updated = data
            .map((Property item) => item.toModel())
            .toList();
        updated[index] = property.toModel();
        try {
          await _localDataSource.saveProperties(updated);
          return Success<Property>(property);
        } on StorageException catch (error) {
          return FailureResult<Property>(StorageFailure(error.message));
        } on Object {
          return const FailureResult<Property>(
            UnknownFailure('Unable to update property.'),
          );
        }
      case FailureResult<List<Property>>(:final failure):
        return FailureResult<Property>(failure);
    }
  }

  @override
  Future<Result<void>> deleteProperty(String id) async {
    final Result<List<Property>> result = await getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        if (!data.any((Property item) => item.id == id)) {
          return FailureResult<void>(
            NotFoundFailure('Property "$id" was not found.'),
          );
        }
        try {
          await _localDataSource.saveProperties(
            data
                .where((Property item) => item.id != id)
                .map((Property item) => item.toModel())
                .toList(growable: false),
          );
          return const Success<void>(null);
        } on StorageException catch (error) {
          return FailureResult<void>(StorageFailure(error.message));
        } on Object {
          return const FailureResult<void>(
            UnknownFailure('Unable to delete property.'),
          );
        }
      case FailureResult<List<Property>>(:final failure):
        return FailureResult<void>(failure);
    }
  }
}
