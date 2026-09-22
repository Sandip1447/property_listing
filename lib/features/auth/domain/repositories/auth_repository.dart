import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthSession?> getCurrentSession();

  Future<bool> isAuthenticated();

  Future<void> logout();
}
