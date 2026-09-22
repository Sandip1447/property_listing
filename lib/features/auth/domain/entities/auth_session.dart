import 'package:equatable/equatable.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';

final class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.accessToken,
  });

  final String userId;
  final String displayName;
  final UserRole role;
  final String accessToken;

  @override
  List<Object?> get props => <Object?>[userId, displayName, role, accessToken];
}
