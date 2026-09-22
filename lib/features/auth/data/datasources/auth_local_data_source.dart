import 'package:injectable/injectable.dart';
import 'package:property_listing/core/constants/auth_constants.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/core/storage/secure_storage_service.dart';
import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:uuid/uuid.dart';

abstract interface class AuthLocalDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthSessionModel?> getCurrentSession();

  Future<void> clearSession();
}

@LazySingleton(as: AuthLocalDataSource)
final class DummyAuthLocalDataSource implements AuthLocalDataSource {
  DummyAuthLocalDataSource(this._secureStorage, this._preferences, this._uuid);

  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;
  final Uuid _uuid;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final _DummyAccount expectedAccount = _accountFor(role);
    if (email.trim().toLowerCase() != expectedAccount.email ||
        password != expectedAccount.password) {
      throw const AuthenticationException(
        'Invalid credentials for the selected role.',
      );
    }

    final AuthSessionModel session = AuthSessionModel(
      userId: expectedAccount.userId,
      displayName: expectedAccount.displayName,
      role: expectedAccount.storedRole,
      accessToken: _uuid.v4(),
    );

    try {
      await _persistSession(session);
      return session;
    } on Object catch (error) {
      await _clearPartiallyWrittenSession();
      throw StorageException('Unable to persist the session: $error');
    }
  }

  @override
  Future<AuthSessionModel?> getCurrentSession() async {
    try {
      final List<String?> secureValues =
          await Future.wait<String?>(<Future<String?>>[
            _secureStorage.read(StorageKeys.accessToken),
            _secureStorage.read(StorageKeys.userId),
            _secureStorage.read(StorageKeys.userRole),
          ]);
      final String? displayName = _preferences.getString(
        StorageKeys.displayName,
      );
      final String? accessToken = secureValues[0];
      final String? userId = secureValues[1];
      final String? role = secureValues[2];

      if (accessToken == null ||
          accessToken.isEmpty ||
          userId == null ||
          userId.isEmpty ||
          !_isKnownRole(role) ||
          displayName == null ||
          displayName.isEmpty) {
        await _clearPartiallyWrittenSession();
        return null;
      }

      return AuthSessionModel(
        userId: userId,
        displayName: displayName,
        role: role!,
        accessToken: accessToken,
      );
    } on Object catch (error) {
      throw StorageException('Unable to restore the session: $error');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _secureStorage.clearSession();
      await _preferences.remove(StorageKeys.displayName);
    } on Object catch (error) {
      throw StorageException('Unable to clear the session: $error');
    }
  }

  _DummyAccount _accountFor(UserRole role) => switch (role) {
    UserRole.user => const _DummyAccount(
      email: AuthConstants.userEmail,
      password: AuthConstants.userPassword,
      userId: AuthConstants.userId,
      displayName: AuthConstants.userDisplayName,
      storedRole: 'user',
    ),
    UserRole.propertyOwner => const _DummyAccount(
      email: AuthConstants.ownerEmail,
      password: AuthConstants.ownerPassword,
      userId: AuthConstants.ownerId,
      displayName: AuthConstants.ownerDisplayName,
      storedRole: 'property_owner',
    ),
  };

  Future<void> _clearPartiallyWrittenSession() async {
    try {
      await _secureStorage.clearSession();
      await _preferences.remove(StorageKeys.displayName);
    } on Object {
      // The original storage failure is more useful to the repository.
    }
  }

  bool _isKnownRole(String? value) =>
      value == 'user' || value == 'property_owner';

  Future<void> _persistSession(AuthSessionModel session) async {
    await _secureStorage.write(StorageKeys.accessToken, session.accessToken);
    await _secureStorage.write(StorageKeys.userId, session.userId);
    await _secureStorage.write(StorageKeys.userRole, session.role);
    await _preferences.setString(StorageKeys.displayName, session.displayName);
  }
}

final class _DummyAccount {
  const _DummyAccount({
    required this.email,
    required this.password,
    required this.userId,
    required this.displayName,
    required this.storedRole,
  });

  final String email;
  final String password;
  final String userId;
  final String displayName;
  final String storedRole;
}
