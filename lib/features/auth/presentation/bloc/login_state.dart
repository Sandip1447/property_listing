import 'package:equatable/equatable.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';

sealed class LoginState extends Equatable {
  const LoginState({required this.isPasswordVisible});

  final bool isPasswordVisible;

  @override
  List<Object?> get props => <Object?>[isPasswordVisible];
}

final class LoginInitial extends LoginState {
  const LoginInitial({super.isPasswordVisible = false});
}

final class LoginLoading extends LoginState {
  const LoginLoading({required super.isPasswordVisible});
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.session, {required super.isPasswordVisible});

  final AuthSession session;

  @override
  List<Object?> get props => <Object?>[...super.props, session];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.message, {required super.isPasswordVisible});

  final String message;

  @override
  List<Object?> get props => <Object?>[...super.props, message];
}
