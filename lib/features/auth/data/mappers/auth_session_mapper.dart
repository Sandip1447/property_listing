import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';

extension AuthSessionModelMapper on AuthSessionModel {
  AuthSession toEntity() => AuthSession(
    userId: userId,
    displayName: displayName,
    role: _roleFromStorage(role),
    accessToken: accessToken,
  );
}

extension AuthSessionEntityMapper on AuthSession {
  AuthSessionModel toModel() => AuthSessionModel(
    userId: userId,
    displayName: displayName,
    role: _roleToStorage(role),
    accessToken: accessToken,
  );
}

UserRole _roleFromStorage(String value) => switch (value) {
  'user' => UserRole.user,
  'property_owner' => UserRole.propertyOwner,
  _ => throw FormatException('Unsupported user role: $value'),
};

String _roleToStorage(UserRole role) => switch (role) {
  UserRole.user => 'user',
  UserRole.propertyOwner => 'property_owner',
};
