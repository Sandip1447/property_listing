import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_filter.dart';
import 'package:property_listing/features/properties/domain/usecases/filter_properties_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_event.dart';
import 'package:property_listing/features/properties/presentation/bloc/property_list_state.dart';

@injectable
final class PropertyListBloc
    extends Bloc<PropertyListEvent, PropertyListState> {
  PropertyListBloc(this._getProperties, this._filterProperties)
    : super(const PropertyListState()) {
    on<PropertyListRequested>(_onRequested);
    on<PropertySearchChanged>(_onSearchChanged);
    on<PropertyFiltersChanged>(_onFiltersChanged);
    on<PropertyFiltersCleared>(_onFiltersCleared);
    on<PropertySortChanged>(_onSortChanged);
    on<PropertyListRefreshed>(_onRefreshed);
  }

  final GetPropertiesUseCase _getProperties;
  final FilterPropertiesUseCase _filterProperties;

  Future<void> _onRequested(
    PropertyListRequested event,
    Emitter<PropertyListState> emit,
  ) => _load(emit);

  Future<void> _onRefreshed(
    PropertyListRefreshed event,
    Emitter<PropertyListState> emit,
  ) => _load(emit);

  void _onSearchChanged(
    PropertySearchChanged event,
    Emitter<PropertyListState> emit,
  ) {
    if (state.status != PropertyListStatus.success) {
      return;
    }
    _emitFiltered(state.filter.copyWith(query: event.query), emit);
  }

  void _onFiltersChanged(
    PropertyFiltersChanged event,
    Emitter<PropertyListState> emit,
  ) {
    if (state.status != PropertyListStatus.success) {
      return;
    }
    _emitFiltered(event.filter, emit);
  }

  void _onFiltersCleared(
    PropertyFiltersCleared event,
    Emitter<PropertyListState> emit,
  ) {
    if (state.status != PropertyListStatus.success) {
      return;
    }
    _emitFiltered(
      PropertyFilter(query: state.filter.query, sort: state.filter.sort),
      emit,
    );
  }

  void _onSortChanged(
    PropertySortChanged event,
    Emitter<PropertyListState> emit,
  ) {
    if (state.status != PropertyListStatus.success) {
      return;
    }
    _emitFiltered(state.filter.copyWith(sort: event.sort), emit);
  }

  void _emitFiltered(PropertyFilter filter, Emitter<PropertyListState> emit) {
    emit(
      PropertyListState(
        status: PropertyListStatus.success,
        allProperties: state.allProperties,
        visibleProperties: _filterProperties(
          properties: state.allProperties,
          filter: filter,
        ),
        filter: filter,
      ),
    );
  }

  Future<void> _load(Emitter<PropertyListState> emit) async {
    emit(
      PropertyListState(
        status: PropertyListStatus.loading,
        allProperties: state.allProperties,
        visibleProperties: state.visibleProperties,
        filter: state.filter,
      ),
    );

    final Result<List<Property>> result = await _getProperties();
    switch (result) {
      case Success<List<Property>>(:final data):
        emit(
          PropertyListState(
            status: PropertyListStatus.success,
            allProperties: data,
            visibleProperties: _filterProperties(
              properties: data,
              filter: state.filter,
            ),
            filter: state.filter,
          ),
        );
      case FailureResult<List<Property>>(:final failure):
        emit(
          PropertyListState(
            status: PropertyListStatus.failure,
            allProperties: state.allProperties,
            visibleProperties: state.visibleProperties,
            filter: state.filter,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
