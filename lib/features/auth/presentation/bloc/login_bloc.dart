import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/usecases/login_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_state.dart';

@injectable
final class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._login) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginPasswordVisibilityChanged>(_onPasswordVisibilityChanged);
  }

  final LoginUseCase _login;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final bool isPasswordVisible = state.isPasswordVisible;
    emit(LoginLoading(isPasswordVisible: isPasswordVisible));

    final Result<AuthSession> result = await _login(
      email: event.email,
      password: event.password,
      role: event.role,
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        emit(LoginSuccess(data, isPasswordVisible: isPasswordVisible));
      case FailureResult<AuthSession>(:final failure):
        emit(
          LoginFailure(failure.message, isPasswordVisible: isPasswordVisible),
        );
    }
  }

  void _onPasswordVisibilityChanged(
    LoginPasswordVisibilityChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial(isPasswordVisible: !state.isPasswordVisible));
  }
}
