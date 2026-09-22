import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/core/widgets/app_empty_view.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_state.dart';
import 'package:property_listing/features/owner_dashboard/presentation/widgets/owner_property_card.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';

class OwnerPropertiesPage extends StatelessWidget {
  const OwnerPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My properties'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sign out',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('owner_properties_add_button'),
        onPressed: () => _openPropertyForm(context),
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Add property'),
      ),
      body: SafeArea(
        child: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
          builder: (BuildContext context, OwnerDashboardState state) {
            return switch (state.status) {
              OwnerDashboardStatus.initial || OwnerDashboardStatus.loading =>
                const AppLoadingView(label: 'Loading your properties…'),
              OwnerDashboardStatus.failure => AppErrorView(
                message: state.errorMessage ?? 'Unable to load properties.',
                onRetry: () => context.read<OwnerDashboardBloc>().add(
                  const OwnerDashboardRequested(),
                ),
              ),
              OwnerDashboardStatus.success => _PropertyGrid(
                properties: state.properties,
                onRefresh: () => _refresh(context),
                onEdit: (Property property) =>
                    _openPropertyForm(context, propertyId: property.id),
                onDelete: (Property property) =>
                    _confirmDelete(context, property),
              ),
            };
          },
        ),
      ),
    );
  }

  Future<void> _openPropertyForm(
    BuildContext context, {
    String? propertyId,
  }) async {
    final bool? changed = await context.pushNamed<bool>(
      propertyId == null
          ? AppRoutes.ownerAddPropertyName
          : AppRoutes.ownerEditPropertyName,
      pathParameters: propertyId == null
          ? const <String, String>{}
          : <String, String>{'propertyId': propertyId},
    );
    if (changed == true && context.mounted) {
      context.read<OwnerDashboardBloc>().add(const OwnerDashboardRefreshed());
    }
  }

  Future<void> _refresh(BuildContext context) async {
    final OwnerDashboardBloc bloc = context.read<OwnerDashboardBloc>();
    bloc.add(const OwnerDashboardRefreshed());
    await bloc.stream.firstWhere(
      (OwnerDashboardState state) =>
          state.status == OwnerDashboardStatus.success ||
          state.status == OwnerDashboardStatus.failure,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Property property) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete property?'),
        content: Text(
          'Delete ${property.name}? This removes it from the local catalogue.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_property'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<OwnerDashboardBloc>().add(
        OwnerPropertyDeleteRequested(property.id),
      );
    }
  }
}

class _PropertyGrid extends StatelessWidget {
  const _PropertyGrid({
    required this.properties,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Property> properties;
  final Future<void> Function() onRefresh;
  final ValueChanged<Property> onEdit;
  final ValueChanged<Property> onDelete;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: properties.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const <Widget>[
                SizedBox(
                  height: 500,
                  child: AppEmptyView(
                    icon: Icons.home_work_outlined,
                    title: 'No properties yet',
                    message:
                        'Properties assigned to your account will appear here.',
                  ),
                ),
              ],
            )
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 390,
                          mainAxisExtent: 270,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final Property property = properties[index];
                      return OwnerPropertyCard(
                        property: property,
                        onEdit: () => onEdit(property),
                        onDelete: () => onDelete(property),
                      );
                    }, childCount: properties.length),
                  ),
                ),
              ],
            ),
    );
  }
}
