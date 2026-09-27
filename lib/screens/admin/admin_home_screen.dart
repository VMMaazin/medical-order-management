import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../models/order_statistics.dart';
import '../../providers/order_provider.dart';
import '../../widgets/admin/dashboard_card.dart';
import '../../widgets/orders/order_overview_section.dart';
import 'chemist/chemists_screen.dart';
import 'doctor/doctors_screen.dart';
import 'medical_rep/medical_reps_screen.dart';
import 'medicine/medicines_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'reports/admin_reports_screen.dart';

class AdminHomeScreen extends ConsumerWidget {
  final AppUser user;
  final void Function(String? statusFilter)? onNavigateToOrders;

  const AdminHomeScreen({
    super.key,
    required this.user,
    this.onNavigateToOrders,
  });

  void _navigateToOrders(
    BuildContext context,
    WidgetRef ref, [
    String status = 'all',
  ]) {
    ref.read(adminOrderStatusFilterProvider.notifier).setFilter(status);
    if (onNavigateToOrders != null) {
      onNavigateToOrders!(status);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdminOrdersScreen(initialFilter: status),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final displayName = user.name.trim().isNotEmpty ? user.name.trim() : 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Order Management'),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(210),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN CONSOLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, $displayName',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pharmaceutical distribution and field operations overview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Header
              Text(
                'Quick Access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Dashboard 2-column Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  final crossAxisCount = isWide ? 3 : 2;
                  final childAspectRatio = isWide ? 1.4 : 1.15;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardCard(
                        title: 'Medicines',
                        subtitle: 'Manage medicines and variants',
                        icon: Icons.medication_outlined,
                        iconColor: const Color(0xFF0D9488),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MedicinesScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Doctors',
                        subtitle: 'Manage doctors',
                        icon: Icons.medical_information_outlined,
                        iconColor: const Color(0xFF0284C7),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DoctorsScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Chemists',
                        subtitle: 'Manage chemist shops',
                        icon: Icons.storefront_outlined,
                        iconColor: const Color(0xFFE11D48),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChemistsScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Representatives',
                        subtitle: 'Manage representatives',
                        icon: Icons.people_alt_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MedicalRepsScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Orders',
                        subtitle: 'View and manage orders',
                        icon: Icons.receipt_long_outlined,
                        iconColor: const Color(0xFFD97706),
                        onTap: () => _navigateToOrders(context, ref, 'all'),
                      ),
                      DashboardCard(
                        title: 'Reports',
                        subtitle: 'View business/order reports',
                        icon: Icons.analytics_outlined,
                        iconColor: const Color(0xFF059669),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AdminReportsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Order Overview Section
              OrderOverviewSection(
                title: 'Order Overview',
                valueLabel: 'Total Value',
                statistics: ref.watch(adminOrderStatisticsProvider).value ??
                    OrderStatistics.empty,
                onStatusTap: (status) =>
                    _navigateToOrders(context, ref, status),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
