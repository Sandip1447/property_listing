sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
