import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';

String? authRedirect({required AuthState authState, required String location}) {
  if (authState is AuthInitial || authState is AuthChecking) {
    return location == AppRoutes.splashPath ? null : AppRoutes.splashPath;
  }

  if (authState case Authenticated(:final session)) {
    final String dashboard = switch (session.role) {
      UserRole.user => AppRoutes.userDashboardPath,
      UserRole.propertyOwner => AppRoutes.ownerDashboardPath,
    };

    if (location == AppRoutes.loginPath || location == AppRoutes.splashPath) {
      return dashboard;
    }
    if (session.role == UserRole.user && location.startsWith('/owner')) {
      return AppRoutes.userDashboardPath;
    }
    if (session.role == UserRole.propertyOwner &&
        location.startsWith('/user')) {
      return AppRoutes.ownerDashboardPath;
    }
    return null;
  }

  return location == AppRoutes.loginPath ? null : AppRoutes.loginPath;
}
