import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/domain/entities/user_role.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';

class RoleDashboardPage extends StatelessWidget {
  const RoleDashboardPage({required this.role, super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = context.select<AuthBloc, AuthSession?>(
      (AuthBloc bloc) => switch (bloc.state) {
        Authenticated(:final session) => session,
        _ => null,
      },
    );
    final String roleName = switch (role) {
      UserRole.user => 'User',
      UserRole.propertyOwner => 'Property Owner',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('$roleName dashboard'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sign out',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  role == UserRole.user
                      ? Icons.search
                      : Icons.apartment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${session?.displayName ?? roleName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  role == UserRole.user
                      ? 'The property catalogue arrives in Phase 4.'
                      : 'Owner properties and enquiries arrive in Phase 7.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
