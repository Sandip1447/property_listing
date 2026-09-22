import 'package:injectable/injectable.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
final class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
