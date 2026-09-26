import 'package:flutter/material.dart';

import 'medicine/medicines_screen.dart';
import 'placeholder_screen.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            Text(
              'Master Directory',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select an entity to manage records and configurations',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _ManagementTile(
              title: 'Medicines',
              subtitle: 'Manage catalog, compositions, and packaging variants',
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
            const SizedBox(height: 12),
            _ManagementTile(
              title: 'Doctors',
              subtitle: 'Manage registered doctor directory and specializations',
              icon: Icons.medical_information_outlined,
              iconColor: const Color(0xFF0284C7),
              onTap: () => _navigateToPlaceholder(
                context,
                sectionName: 'Doctors',
                icon: Icons.medical_information_outlined,
                description:
                    'Maintain doctor database, contact details, and clinic affiliations.',
              ),
            ),
            const SizedBox(height: 12),
            _ManagementTile(
              title: 'Chemists',
              subtitle: 'Manage retail pharmacy and chemist shop records',
              icon: Icons.storefront_outlined,
              iconColor: const Color(0xFFE11D48),
              onTap: () => _navigateToPlaceholder(
                context,
                sectionName: 'Chemists',
                icon: Icons.storefront_outlined,
                description:
                    'Manage chemist shops, delivery addresses, and phone contacts.',
              ),
            ),
            const SizedBox(height: 12),
            _ManagementTile(
              title: 'Medical Representatives',
              subtitle: 'Manage field representatives and account statuses',
              icon: Icons.people_alt_outlined,
              iconColor: const Color(0xFF7C3AED),
              onTap: () => _navigateToPlaceholder(
                context,
                sectionName: 'Medical Representatives',
                icon: Icons.people_alt_outlined,
                description:
                    'Review representative credentials, territory assignments, and statuses.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
