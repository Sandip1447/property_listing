import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/favourites/domain/usecases/get_favourite_ids_use_case.dart';
import 'package:property_listing/features/favourites/domain/usecases/toggle_favourite_use_case.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_event.dart';
import 'package:property_listing/features/favourites/presentation/bloc/favourite_state.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/usecases/get_properties_use_case.dart';

@injectable
final class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  FavouriteBloc(
    this._getFavouriteIds,
    this._toggleFavourite,
    this._getProperties,
  ) : super(const FavouriteState()) {
    on<FavouritesRequested>(_onRequested);
    on<FavouriteToggled>(_onToggled);
  }

  final GetFavouriteIdsUseCase _getFavouriteIds;
  final ToggleFavouriteUseCase _toggleFavourite;
  final GetPropertiesUseCase _getProperties;

  Future<void> _onRequested(
    FavouritesRequested event,
    Emitter<FavouriteState> emit,
  ) async {
    emit(
      FavouriteState(
        status: FavouriteStatus.loading,
        favouriteIds: state.favouriteIds,
        properties: state.properties,
      ),
    );
    try {
      final Set<String> ids = await _getFavouriteIds();
      final Result<List<Property>> propertyResult = await _getProperties();
      switch (propertyResult) {
        case Success<List<Property>>(:final data):
          emit(
            FavouriteState(
              status: FavouriteStatus.success,
              favouriteIds: Set<String>.unmodifiable(ids),
              properties: data,
            ),
          );
        case FailureResult<List<Property>>(:final failure):
          emit(
            FavouriteState(
              status: FavouriteStatus.failure,
              favouriteIds: Set<String>.unmodifiable(ids),
              properties: state.properties,
              errorMessage: failure.message,
            ),
          );
      }
    } on Object {
      emit(
        FavouriteState(
          status: FavouriteStatus.failure,
          favouriteIds: state.favouriteIds,
          properties: state.properties,
          errorMessage: 'Unable to load favourites.',
        ),
      );
    }
  }

  Future<void> _onToggled(
    FavouriteToggled event,
    Emitter<FavouriteState> emit,
  ) async {
    try {
      final Set<String> ids = await _toggleFavourite(event.propertyId);
      emit(
        FavouriteState(
          status: FavouriteStatus.success,
          favouriteIds: Set<String>.unmodifiable(ids),
          properties: state.properties,
        ),
      );
    } on Object {
      emit(
        FavouriteState(
          status: FavouriteStatus.failure,
          favouriteIds: state.favouriteIds,
          properties: state.properties,
          errorMessage: 'Unable to update favourites.',
        ),
      );
    }
  }
}
