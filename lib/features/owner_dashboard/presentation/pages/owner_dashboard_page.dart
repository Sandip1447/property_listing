import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:property_listing/app/router/app_routes.dart';
import 'package:property_listing/core/widgets/app_empty_view.dart';
import 'package:property_listing/core/widgets/app_error_view.dart';
import 'package:property_listing/core/widgets/app_loading_view.dart';
import 'package:property_listing/features/auth/domain/entities/auth_session.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_event.dart';
import 'package:property_listing/features/auth/presentation/bloc/auth_state.dart';
import 'package:property_listing/features/interests/domain/entities/property_interest.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_event.dart';
import 'package:property_listing/features/owner_dashboard/presentation/bloc/owner_dashboard_state.dart';
import 'package:property_listing/features/owner_dashboard/presentation/widgets/owner_interest_card.dart';
import 'package:property_listing/features/properties/domain/entities/property.dart';
import 'package:property_listing/features/properties/domain/entities/property_enums.dart';
import 'package:property_listing/features/properties/presentation/utils/property_labels.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthSession? session = context.select<AuthBloc, AuthSession?>(
      (AuthBloc bloc) => switch (bloc.state) {
        Authenticated(:final session) => session,
        _ => null,
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner dashboard'),
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
        key: const Key('view_owner_properties_button'),
        onPressed: () => context.pushNamed(AppRoutes.ownerPropertiesName),
        icon: const Icon(Icons.home_work_outlined),
        label: const Text('View my properties'),
      ),
      body: SafeArea(
        child: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
          builder: (BuildContext context, OwnerDashboardState state) =>
              switch (state.status) {
                OwnerDashboardStatus.initial || OwnerDashboardStatus.loading =>
                  const AppLoadingView(label: 'Loading owner dashboard…'),
                OwnerDashboardStatus.failure => AppErrorView(
                  message:
                      state.errorMessage ?? 'Unable to load owner dashboard.',
                  onRetry: () => context.read<OwnerDashboardBloc>().add(
                    const OwnerDashboardRequested(),
                  ),
                ),
                OwnerDashboardStatus.success => _OwnerDashboardContent(
                  displayName: session?.displayName ?? 'Owner',
                  state: state,
                  onRefresh: () => _refresh(context),
                ),
              },
        ),
      ),
    );
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
}

class _OwnerDashboardContent extends StatelessWidget {
  const _OwnerDashboardContent({
    required this.displayName,
    required this.state,
    required this.onRefresh,
  });

  final String displayName;
  final OwnerDashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: const Key('owner_dashboard_scroll_view'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Welcome, $displayName',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here is the latest activity for your properties.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      _OwnerStats(state: state),
                      if (state.properties.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        _PropertyStatusChart(properties: state.properties),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          _SectionHeader(
            title: 'Recent interests',
            count: state.totalInterests,
          ),
          if (state.interests.isEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: AppEmptyView(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'No enquiries yet',
                  message:
                      'Interest submitted for your properties will appear here.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  final PropertyInterest interest = state.interests[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index == state.interests.length - 1 ? 0 : 12,
                        ),
                        child: OwnerInterestCard(
                          interest: interest,
                          onStatusChanged: (status) => context
                              .read<OwnerDashboardBloc>()
                              .add(
                                OwnerInterestStatusChanged(
                                  interestId: interest.id,
                                  status: status,
                                ),
                              ),
                        ),
                      ),
                    ),
                  );
                }, childCount: state.interests.length),
              ),
            ),
        ],
      ),
    );
  }

}

class _OwnerStats extends StatelessWidget {
  const _OwnerStats({required this.state});

  final OwnerDashboardState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 640;
        final double width = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _StatCard(
              width: width,
              icon: Icons.home_work_outlined,
              label: 'Total properties',
              value: state.totalProperties,
            ),
            _StatCard(
              width: width,
              icon: Icons.check_circle_outline,
              label: 'Available properties',
              value: state.availableProperties,
            ),
            _StatCard(
              width: width,
              icon: Icons.mark_email_unread_outlined,
              label: 'Total interests',
              value: state.totalInterests,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(icon, color: colors.onPrimaryContainer, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$value',
                      key: Key(
                        'owner_stat_${label.toLowerCase().replaceAll(' ', '_')}',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyStatusChart extends StatelessWidget {
  const _PropertyStatusChart({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Map<PropertyStatus, int> counts = <PropertyStatus, int>{
      for (final PropertyStatus status in PropertyStatus.values)
        status: properties
            .where((Property property) => property.status == status)
            .length,
    };
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Property status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            ...PropertyStatus.values.map((PropertyStatus status) {
              final int count = counts[status]!;
              final double fraction = properties.isEmpty
                  ? 0
                  : count / properties.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 130, child: Text(status.label)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 20, child: Text('$count')),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Badge(label: Text('$count')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
