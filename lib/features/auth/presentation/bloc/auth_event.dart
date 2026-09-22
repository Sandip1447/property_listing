import 'package:equatable/equatable.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSessionChanged extends AuthEvent {
  const AuthSessionChanged(this.session);

  final AuthSession? session;

  @override
  List<Object?> get props => <Object?>[session];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
