import 'package:equatable/equatable.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class Authenticated extends AuthState {
  const Authenticated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => <Object?>[session];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
