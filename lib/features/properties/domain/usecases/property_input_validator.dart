import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/features/properties/domain/entities/property_input.dart';

abstract final class PropertyInputValidator {
  static String? validate(PropertyInput input) {
    final String? nameError = Validators.required(
      input.name,
      fieldName: 'Property name',
    );
    if (nameError != null) {
      return nameError;
    }
    if (input.name.trim().length < 2) {
      return 'Property name must contain at least 2 characters.';
    }
    final String? locationError = Validators.required(
      input.location,
      fieldName: 'Location',
    );
    if (locationError != null) {
      return locationError;
    }
    if (input.price <= 0) {
      return 'Price must be greater than zero.';
    }
    if (input.areaSqFt <= 0) {
      return 'Area must be greater than zero.';
    }
    if (input.bedrooms <= 0) {
      return 'Bedrooms must be greater than zero.';
    }
    if (input.bathrooms <= 0) {
      return 'Bathrooms must be greater than zero.';
    }
    if (input.description.trim().length < 10) {
      return 'Description must contain at least 10 characters.';
    }
    if (input.imageUrl.trim().isEmpty) {
      return 'Select a property image.';
    }
    return null;
  }
}
