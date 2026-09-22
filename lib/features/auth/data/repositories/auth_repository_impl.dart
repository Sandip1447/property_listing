import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:property_listing/features/auth/data/mappers/auth_session_mapper.dart';
import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<AuthSession?> getCurrentSession() async {
    try {
      final AuthSessionModel? model = await _localDataSource
          .getCurrentSession();
      return model?.toEntity();
    } on Object {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async => await getCurrentSession() != null;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final AuthSessionModel model = await _localDataSource.login(
        email: email,
        password: password,
        role: role,
      );
      return Success<AuthSession>(model.toEntity());
    } on AuthenticationException catch (error) {
      return FailureResult<AuthSession>(AuthenticationFailure(error.message));
    } on StorageException catch (error) {
      return FailureResult<AuthSession>(StorageFailure(error.message));
    } on Object {
      return const FailureResult<AuthSession>(
        UnknownFailure('Unable to sign in. Please try again.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _localDataSource.clearSession();
    } on Object {
      // The repository contract intentionally makes logout idempotent.
    }
  }
}
