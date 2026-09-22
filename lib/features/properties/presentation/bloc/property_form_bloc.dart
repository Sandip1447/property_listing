import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/usecases/add_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owned_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/update_property_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_form_state.dart';

@injectable
final class PropertyFormBloc
    extends Bloc<PropertyFormEvent, PropertyFormState> {
  PropertyFormBloc(
    this._getOwnedPropertyById,
    this._addProperty,
    this._updateProperty,
  ) : super(const PropertyFormState()) {
    on<PropertyFormRequested>(_onRequested);
    on<PropertyFormSubmitted>(_onSubmitted);
  }

  final GetOwnedPropertyByIdUseCase _getOwnedPropertyById;
  final AddPropertyUseCase _addProperty;
  final UpdatePropertyUseCase _updateProperty;

  Future<void> _onRequested(
    PropertyFormRequested event,
    Emitter<PropertyFormState> emit,
  ) async {
    if (event.propertyId == null) {
      emit(const PropertyFormState(status: PropertyFormStatus.ready));
      return;
    }
    emit(const PropertyFormState(status: PropertyFormStatus.loading));
    final Result<Property> result = await _getOwnedPropertyById(
      event.propertyId!,
    );
    switch (result) {
      case Success<Property>(:final data):
        emit(
          PropertyFormState(status: PropertyFormStatus.ready, property: data),
        );
      case FailureResult<Property>(:final failure):
        emit(
          PropertyFormState(
            status: PropertyFormStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onSubmitted(
    PropertyFormSubmitted event,
    Emitter<PropertyFormState> emit,
  ) async {
    emit(
      PropertyFormState(
        status: PropertyFormStatus.submitting,
        property: state.property,
      ),
    );
    final Result<Property> result = event.propertyId == null
        ? await _addProperty(event.input)
        : await _updateProperty(
            propertyId: event.propertyId!,
            input: event.input,
          );
    switch (result) {
      case Success<Property>(:final data):
        emit(
          PropertyFormState(status: PropertyFormStatus.success, property: data),
        );
      case FailureResult<Property>(:final failure):
        emit(
          PropertyFormState(
            status: PropertyFormStatus.failure,
            property: state.property,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
