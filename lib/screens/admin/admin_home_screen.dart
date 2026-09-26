import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../widgets/admin/dashboard_card.dart';
import 'placeholder_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final AppUser user;

  const AdminHomeScreen({
    super.key,
    required this.user,
  });

  void _navigateToPlaceholder(
    BuildContext context, {
    required String sectionName,
    required IconData icon,
    required String description,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          sectionName: sectionName,
          icon: icon,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Medicines',
                          icon: Icons.medication_outlined,
                          description:
                              'Manage drug catalog, brand names, compositions, and dosage variants.',
                        ),
                      ),
                      DashboardCard(
                        title: 'Doctors',
                        subtitle: 'Manage doctors',
                        icon: Icons.medical_information_outlined,
                        iconColor: const Color(0xFF0284C7),
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Doctors',
                          icon: Icons.medical_information_outlined,
                          description:
                              'Manage doctor profiles, specializations, contact details, and affiliations.',
                        ),
                      ),
                      DashboardCard(
                        title: 'Chemists',
                        subtitle: 'Manage chemist shops',
                        icon: Icons.storefront_outlined,
                        iconColor: const Color(0xFFE11D48),
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Chemists',
                          icon: Icons.storefront_outlined,
                          description:
                              'Manage chemist shops, pharmacy addresses, contacts, and delivery locations.',
                        ),
                      ),
                      DashboardCard(
                        title: 'Representatives',
                        subtitle: 'Manage representatives',
                        icon: Icons.people_alt_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Medical Representatives',
                          icon: Icons.people_alt_outlined,
                          description:
                              'Manage medical representative accounts, assignments, and active statuses.',
                        ),
                      ),
                      DashboardCard(
                        title: 'Orders',
                        subtitle: 'View and manage orders',
                        icon: Icons.receipt_long_outlined,
                        iconColor: const Color(0xFFD97706),
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Orders',
                          icon: Icons.receipt_long_outlined,
                          description:
                              'Review submitted orders from representatives, update status, and generate PDFs.',
                        ),
                      ),
                      DashboardCard(
                        title: 'Reports',
                        subtitle: 'View business/order reports',
                        icon: Icons.analytics_outlined,
                        iconColor: const Color(0xFF059669),
                        onTap: () => _navigateToPlaceholder(
                          context,
                          sectionName: 'Reports',
                          icon: Icons.analytics_outlined,
                          description:
                              'View sales analytics, doctor ordering trends, and representative performance.',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
