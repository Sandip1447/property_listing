import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/usecases/get_owner_interests_use_case.dart';
import 'package:property_listing/features/interests/domain/usecases/update_interest_status_use_case.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_state.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/usecases/delete_property_use_case.dart';
import 'package:property_listing/features/properties/domain/usecases/get_owner_properties_use_case.dart';

@injectable
final class OwnerDashboardBloc
    extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  OwnerDashboardBloc(
    this._getOwnerProperties,
    this._getOwnerInterests,
    this._deleteProperty,
    [this._updateInterestStatus,]
  ) : super(const OwnerDashboardState()) {
    on<OwnerDashboardRequested>(_onRequested);
    on<OwnerDashboardRefreshed>(_onRefreshed);
    on<OwnerPropertyDeleteRequested>(_onDeleteRequested);
    on<OwnerInterestStatusChanged>(_onInterestStatusChanged);
  }

  final GetOwnerPropertiesUseCase _getOwnerProperties;
  final GetOwnerInterestsUseCase _getOwnerInterests;
  final DeletePropertyUseCase _deleteProperty;
  final UpdateInterestStatusUseCase? _updateInterestStatus;

  Future<void> _onRequested(
    OwnerDashboardRequested event,
    Emitter<OwnerDashboardState> emit,
  ) => _load(emit);

  Future<void> _onRefreshed(
    OwnerDashboardRefreshed event,
    Emitter<OwnerDashboardState> emit,
  ) => _load(emit);

  Future<void> _load(Emitter<OwnerDashboardState> emit) async {
    emit(
      OwnerDashboardState(
        status: OwnerDashboardStatus.loading,
        properties: state.properties,
        interests: state.interests,
      ),
    );

    final Result<List<Property>> propertyResult = await _getOwnerProperties();
    switch (propertyResult) {
      case FailureResult<List<Property>>(:final failure):
        emit(
          OwnerDashboardState(
            status: OwnerDashboardStatus.failure,
            properties: state.properties,
            interests: state.interests,
            errorMessage: failure.message,
          ),
        );
        return;
      case Success<List<Property>>(data: final properties):
        final Result<List<PropertyInterest>> interestResult =
            await _getOwnerInterests();
        switch (interestResult) {
          case Success<List<PropertyInterest>>(data: final interests):
            emit(
              OwnerDashboardState(
                status: OwnerDashboardStatus.success,
                properties: properties,
                interests: interests,
              ),
            );
          case FailureResult<List<PropertyInterest>>(:final failure):
            emit(
              OwnerDashboardState(
                status: OwnerDashboardStatus.failure,
                properties: properties,
                interests: state.interests,
                errorMessage: failure.message,
              ),
            );
        }

    }
  }

  Future<void> _onInterestStatusChanged(
    OwnerInterestStatusChanged event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    final UpdateInterestStatusUseCase? updateInterestStatus =
        _updateInterestStatus;
    if (updateInterestStatus == null) {
      return;
    }
    final Result<PropertyInterest> result = await updateInterestStatus(
      interestId: event.interestId,
      status: event.status,
    );
    switch (result) {
      case Success<PropertyInterest>(:final data):
        emit(
          OwnerDashboardState(
            status: OwnerDashboardStatus.success,
            properties: state.properties,
            interests: state.interests
                .map((PropertyInterest item) => item.id == data.id ? data : item)
                .toList(growable: false),
          ),
        );
      case FailureResult<PropertyInterest>(:final failure):
        emit(
          OwnerDashboardState(
            status: OwnerDashboardStatus.failure,
            properties: state.properties,
            interests: state.interests,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onDeleteRequested(
    OwnerPropertyDeleteRequested event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(
      OwnerDashboardState(
        status: OwnerDashboardStatus.loading,
        properties: state.properties,
        interests: state.interests,
      ),
    );
    final Result<void> result = await _deleteProperty(event.propertyId);
    switch (result) {
      case Success<void>():
        await _load(emit);
      case FailureResult<void>(:final failure):
        emit(
          OwnerDashboardState(
            status: OwnerDashboardStatus.failure,
            properties: state.properties,
            interests: state.interests,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
