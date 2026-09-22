import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';

final class MockAuthLocalDataSource extends Mock
    implements AuthLocalDataSource {}

void main() {
  late MockAuthLocalDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  test('maps a successful login model to an entity', () async {
    const AuthSessionModel model = AuthSessionModel(
      userId: 'U001',
      displayName: 'Demo User',
      role: 'user',
      accessToken: 'token',
    );
    when(
      () => dataSource.login(
        email: 'user@propertydemo.com',
        password: 'User@123',
        role: UserRole.user,
      ),
    ).thenAnswer((_) async => model);

    final Result<AuthSession> result = await repository.login(
      email: 'user@propertydemo.com',
      password: 'User@123',
      role: UserRole.user,
    );

    expect(result, isA<Success<AuthSession>>());
    expect((result as Success<AuthSession>).data.role, UserRole.user);
  });

  test('maps invalid credentials to AuthenticationFailure', () async {
    when(
      () => dataSource.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        role: UserRole.user,
      ),
    ).thenThrow(const AuthenticationException('Invalid credentials.'));

    final Result<AuthSession> result = await repository.login(
      email: 'wrong@example.com',
      password: 'wrong',
      role: UserRole.user,
    );

    expect(
      (result as FailureResult<AuthSession>).failure,
      const AuthenticationFailure('Invalid credentials.'),
    );
  });

  test('maps persistence errors to StorageFailure', () async {
    when(
      () => dataSource.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
        role: UserRole.user,
      ),
    ).thenThrow(const StorageException('Storage unavailable.'));

    final Result<AuthSession> result = await repository.login(
      email: 'user@propertydemo.com',
      password: 'User@123',
      role: UserRole.user,
    );

    expect(
      (result as FailureResult<AuthSession>).failure,
      const StorageFailure('Storage unavailable.'),
    );
  });
}
