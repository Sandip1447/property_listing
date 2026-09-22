import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:property_listing/core/constants/auth_constants.dart';
import 'package:property_listing/core/constants/storage_keys.dart';
import 'package:property_listing/core/error/exceptions.dart';
import 'package:property_listing/core/storage/preferences_service.dart';
import 'package:property_listing/core/storage/secure_storage_service.dart';
import 'package:property_listing/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:property_listing/features/auth/data/models/auth_session_model.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:uuid/uuid.dart';

final class MockSecureStorageService extends Mock
    implements SecureStorageService {}

final class MockPreferencesService extends Mock implements PreferencesService {}

void main() {
  late MockSecureStorageService secureStorage;
  late MockPreferencesService preferences;
  late DummyAuthLocalDataSource dataSource;

  setUp(() {
    secureStorage = MockSecureStorageService();
    preferences = MockPreferencesService();
    dataSource = DummyAuthLocalDataSource(
      secureStorage,
      preferences,
      const Uuid(),
    );
  });

  test('authenticates and persists the documented user account', () async {
    when(() => secureStorage.write(any(), any())).thenAnswer((_) async {});
    when(() => preferences.setString(any(), any())).thenAnswer((_) async {});

    final AuthSessionModel session = await dataSource.login(
      email: AuthConstants.userEmail,
      password: AuthConstants.userPassword,
      role: UserRole.user,
    );

    expect(session.userId, AuthConstants.userId);
    expect(session.role, 'user');
    expect(session.accessToken, isNotEmpty);
    verify(
      () => secureStorage.write(StorageKeys.userId, AuthConstants.userId),
    ).called(1);
    verify(
      () => preferences.setString(
        StorageKeys.displayName,
        AuthConstants.userDisplayName,
      ),
    ).called(1);
  });

  test('rejects credentials that do not match the selected role', () async {
    expect(
      () => dataSource.login(
        email: AuthConstants.userEmail,
        password: AuthConstants.userPassword,
        role: UserRole.propertyOwner,
      ),
      throwsA(isA<AuthenticationException>()),
    );

    verifyNever(() => secureStorage.write(any(), any()));
  });

  test('authenticates the documented property owner account', () async {
    when(() => secureStorage.write(any(), any())).thenAnswer((_) async {});
    when(() => preferences.setString(any(), any())).thenAnswer((_) async {});

    final AuthSessionModel session = await dataSource.login(
      email: AuthConstants.ownerEmail,
      password: AuthConstants.ownerPassword,
      role: UserRole.propertyOwner,
    );

    expect(session.userId, AuthConstants.ownerId);
    expect(session.role, 'property_owner');
    verify(
      () => secureStorage.write(StorageKeys.userRole, 'property_owner'),
    ).called(1);
  });

  test('restores a complete persisted session', () async {
    when(
      () => secureStorage.read(StorageKeys.accessToken),
    ).thenAnswer((_) async => 'token');
    when(
      () => secureStorage.read(StorageKeys.userId),
    ).thenAnswer((_) async => AuthConstants.ownerId);
    when(
      () => secureStorage.read(StorageKeys.userRole),
    ).thenAnswer((_) async => 'property_owner');
    when(
      () => preferences.getString(StorageKeys.displayName),
    ).thenReturn(AuthConstants.ownerDisplayName);

    final AuthSessionModel? session = await dataSource.getCurrentSession();

    expect(session?.userId, AuthConstants.ownerId);
    expect(session?.role, 'property_owner');
  });

  test('logout removes secure session data and display name', () async {
    when(secureStorage.clearSession).thenAnswer((_) async {});
    when(
      () => preferences.remove(StorageKeys.displayName),
    ).thenAnswer((_) async {});

    await dataSource.clearSession();

    verify(secureStorage.clearSession).called(1);
    verify(() => preferences.remove(StorageKeys.displayName)).called(1);
  });
}
