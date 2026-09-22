import 'package:injectable/injectable.dart';
import 'package:property_listing/core/error/failures.dart';
import 'package:property_listing/core/error/result.dart';
import 'package:property_listing/core/utils/validators.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
final class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final String? emailError = Validators.email(email);
    if (emailError != null) {
      return FailureResult<AuthSession>(ValidationFailure(emailError));
    }

    final String? passwordError = Validators.required(
      password,
      fieldName: 'Password',
    );
    if (passwordError != null) {
      return FailureResult<AuthSession>(ValidationFailure(passwordError));
    }

    return _repository.login(
      email: email.trim(),
      password: password,
      role: role,
    );
  }
}
