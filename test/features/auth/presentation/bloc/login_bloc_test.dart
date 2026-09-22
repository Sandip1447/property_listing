import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';
import 'package:property_listing/features/auth/domain/usecases/login_use_case.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/login_state.dart';

final class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const AuthSession session = AuthSession(
    userId: 'U001',
    displayName: 'Demo User',
    role: UserRole.user,
    accessToken: 'token',
  );
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  blocTest<LoginBloc, LoginState>(
    'emits loading then success for valid credentials',
    setUp: () {
      when(
        () => repository.login(
          email: 'user@propertydemo.com',
          password: 'User@123',
          role: UserRole.user,
        ),
      ).thenAnswer((_) async => const Success<AuthSession>(session));
    },
    build: () => LoginBloc(LoginUseCase(repository)),
    act: (LoginBloc bloc) => bloc.add(
      const LoginSubmitted(
        email: 'user@propertydemo.com',
        password: 'User@123',
        role: UserRole.user,
      ),
    ),
    expect: () => const <LoginState>[
      LoginLoading(isPasswordVisible: false),
      LoginSuccess(session, isPasswordVisible: false),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'returns validation failure without calling the repository',
    build: () => LoginBloc(LoginUseCase(repository)),
    act: (LoginBloc bloc) => bloc.add(
      const LoginSubmitted(
        email: 'not-an-email',
        password: 'User@123',
        role: UserRole.user,
      ),
    ),
    expect: () => const <LoginState>[
      LoginLoading(isPasswordVisible: false),
      LoginFailure('Enter a valid email address.', isPasswordVisible: false),
    ],
    verify: (LoginBloc bloc) {
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: UserRole.user,
        ),
      );
    },
  );

  blocTest<LoginBloc, LoginState>(
    'surfaces repository authentication failures',
    setUp: () {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: UserRole.user,
        ),
      ).thenAnswer(
        (_) async => const FailureResult<AuthSession>(
          AuthenticationFailure('Invalid credentials.'),
        ),
      );
    },
    build: () => LoginBloc(LoginUseCase(repository)),
    act: (LoginBloc bloc) => bloc.add(
      const LoginSubmitted(
        email: 'user@propertydemo.com',
        password: 'wrong',
        role: UserRole.user,
      ),
    ),
    expect: () => const <LoginState>[
      LoginLoading(isPasswordVisible: false),
      LoginFailure('Invalid credentials.', isPasswordVisible: false),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'toggles password visibility',
    build: () => LoginBloc(LoginUseCase(repository)),
    act: (LoginBloc bloc) => bloc.add(const LoginPasswordVisibilityChanged()),
    expect: () => const <LoginState>[LoginInitial(isPasswordVisible: true)],
  );
}
