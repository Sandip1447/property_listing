import 'package:flutter_test/flutter_test.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/app/router/route_guards.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';

void main() {
  const AuthSession userSession = AuthSession(
    userId: 'U001',
    displayName: 'Demo User',
    role: UserRole.user,
    accessToken: 'token',
  );
  const AuthSession ownerSession = AuthSession(
    userId: 'O001',
    displayName: 'Demo Owner',
    role: UserRole.propertyOwner,
    accessToken: 'token',
  );

  test('sends unauthenticated users to login', () {
    expect(
      authRedirect(
        authState: const Unauthenticated(),
        location: AppRoutes.userDashboardPath,
      ),
      AppRoutes.loginPath,
    );
  });

  test('sends an authenticated user away from owner routes', () {
    expect(
      authRedirect(
        authState: const Authenticated(userSession),
        location: AppRoutes.ownerInterestsPath,
      ),
      AppRoutes.userDashboardPath,
    );
  });

  test('sends an authenticated owner away from user routes', () {
    expect(
      authRedirect(
        authState: const Authenticated(ownerSession),
        location: AppRoutes.userPropertiesPath,
      ),
      AppRoutes.ownerDashboardPath,
    );
  });

  test('sends authenticated login visitors to their dashboard', () {
    expect(
      authRedirect(
        authState: const Authenticated(ownerSession),
        location: AppRoutes.loginPath,
      ),
      AppRoutes.ownerDashboardPath,
    );
  });
}
