import 'package:injectable/injectable.dart';
import 'package:property_listing/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
final class IsAuthenticatedUseCase {
  const IsAuthenticatedUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.isAuthenticated();
}
