import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/interests/domain/usecases/submit_interest_use_case.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_event.dart';
import 'package:property_listing/features/interests/presentation/bloc/submit_interest_state.dart';

@injectable
final class SubmitInterestBloc
    extends Bloc<SubmitInterestEvent, SubmitInterestState> {
  SubmitInterestBloc(this._submitInterest)
    : super(const SubmitInterestState()) {
    on<SubmitInterestSubmitted>(_onSubmitted);
    on<SubmitInterestReset>(_onReset);
  }

  final SubmitInterestUseCase _submitInterest;

  Future<void> _onSubmitted(
    SubmitInterestSubmitted event,
    Emitter<SubmitInterestState> emit,
  ) async {
    emit(const SubmitInterestState(status: SubmitInterestStatus.submitting));
    final Result<PropertyInterest> result = await _submitInterest(
      propertyId: event.propertyId,
      fullName: event.fullName,
      mobileNumber: event.mobileNumber,
      email: event.email,
      message: event.message,
    );

    switch (result) {
      case Success<PropertyInterest>(:final data):
        emit(
          SubmitInterestState(
            status: SubmitInterestStatus.success,
            interest: data,
          ),
        );
      case FailureResult<PropertyInterest>(:final failure):
        emit(
          SubmitInterestState(
            status: SubmitInterestStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void _onReset(SubmitInterestReset event, Emitter<SubmitInterestState> emit) {
    emit(const SubmitInterestState());
  }
}
