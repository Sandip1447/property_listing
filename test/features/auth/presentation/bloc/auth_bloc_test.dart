import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/get_current_session_use_case.dart';
import 'package:property_listing/features/auth/domain/usecases/logout_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession session = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  AuthBloc buildBloc() =>
      AuthBloc(GetCurrentSessionUseCase(repository), LogoutUseCase(repository));

  blocTest<AuthBloc, AuthState>(
    'restores an authenticated session on startup',
    setUp: () {
      when(repository.getCurrentSession).thenAnswer((_) async => session);
    },
    build: buildBloc,
    act: (AuthBloc bloc) => bloc.add(const AuthStarted()),
    expect: () => const <AuthState>[AuthChecking(), Authenticated(session)],
  );

  blocTest<AuthBloc, AuthState>(
    'becomes unauthenticated when no session exists',
    setUp: () {
      when(repository.getCurrentSession).thenAnswer((_) async => null);
    },
    build: buildBloc,
    act: (AuthBloc bloc) => bloc.add(const AuthStarted()),
    expect: () => const <AuthState>[AuthChecking(), Unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'clears the session on logout',
    setUp: () {
      when(repository.logout).thenAnswer((_) async {});
    },
    seed: () => const Authenticated(session),
    build: buildBloc,
    act: (AuthBloc bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => const <AuthState>[AuthChecking(), Unauthenticated()],
    verify: (AuthBloc bloc) {
      verify(repository.logout).called(1);
    },
  );
}
