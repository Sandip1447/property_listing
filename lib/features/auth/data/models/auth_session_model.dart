final class AuthSessionModel {
  const AuthSessionModel({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.accessToken,
  });

  final String userId;
  final String displayName;
  final String role;
  final String accessToken;
}
