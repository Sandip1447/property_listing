import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/usecases/get_property_by_id_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_detail_state.dart';

@injectable
final class PropertyDetailBloc
    extends Bloc<PropertyDetailEvent, PropertyDetailState> {
  PropertyDetailBloc(this._getPropertyById)
    : super(const PropertyDetailState()) {
    on<PropertyDetailRequested>(_onRequested);
  }

  final GetPropertyByIdUseCase _getPropertyById;

  Future<void> _onRequested(
    PropertyDetailRequested event,
    Emitter<PropertyDetailState> emit,
  ) async {
    emit(const PropertyDetailState(status: PropertyDetailStatus.loading));
    final Result<Property> result = await _getPropertyById(event.propertyId);

    switch (result) {
      case Success<Property>(:final data):
        emit(
          PropertyDetailState(
            status: PropertyDetailStatus.success,
            property: data,
          ),
        );
      case FailureResult<Property>(:final failure):
        emit(
          PropertyDetailState(
            status: PropertyDetailStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
