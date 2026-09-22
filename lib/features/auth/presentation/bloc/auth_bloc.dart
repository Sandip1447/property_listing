import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/auth/domain/usecases/logout_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';

@injectable
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._getCurrentSession, this._logout) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSessionChanged>(_onSessionChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentSessionUseCase _getCurrentSession;
  final LogoutUseCase _logout;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthChecking());
    try {
      final AuthSession? session = await _getCurrentSession();
      emit(session == null ? const Unauthenticated() : Authenticated(session));
    } on Object {
      emit(const AuthFailure('Unable to restore your session.'));
    }
  }

  void _onSessionChanged(AuthSessionChanged event, Emitter<AuthState> emit) {
    final AuthSession? session = event.session;
    emit(session == null ? const Unauthenticated() : Authenticated(session));
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthChecking());
    try {
      await _logout();
      emit(const Unauthenticated());
    } on Object {
      emit(const AuthFailure('Unable to sign out. Please try again.'));
    }
  }
}
