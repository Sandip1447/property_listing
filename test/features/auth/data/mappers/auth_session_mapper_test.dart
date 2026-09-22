import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/features/auth/data/mappers/auth_session_mapper.dart';
import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';

void main() {
  test('maps a stored owner role explicitly to the domain enum', () {
    const AuthSessionModel model = AuthSessionModel(
      userId: 'O001',
      displayName: 'Demo Owner',
      role: 'property_owner',
      accessToken: 'token',
    );

    expect(model.toEntity().role, UserRole.propertyOwner);
  });

  test('maps a domain role to an explicit storage value', () {
    const AuthSession session = AuthSession(
      userId: 'U001',
      displayName: 'Demo User',
      role: UserRole.user,
      accessToken: 'token',
    );

    expect(session.toModel().role, 'user');
  });

  test('rejects an unknown persisted role', () {
    const AuthSessionModel model = AuthSessionModel(
      userId: 'X001',
      displayName: 'Unknown',
      role: 'admin',
      accessToken: 'token',
    );

    expect(model.toEntity, throwsFormatException);
  });
}
