import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';

class AdminProfileScreen extends ConsumerWidget {
  final AppUser user;

  const AdminProfileScreen({
    super.key,
    required this.user,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'A';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final displayName = user.name.trim().isNotEmpty ? user.name.trim() : 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // User Avatar & Name Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _getInitials(user.name),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(80),
                        ),
                      ),
                      child: Text(
                        'ADMINISTRATOR',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(128),
                  ),
                ),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Full Name'),
                        subtitle: Text(displayName),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user.email.isNotEmpty ? user.email : 'N/A'),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: Icon(
                          Icons.badge_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('Role'),
                        subtitle: Text(user.role.toUpperCase()),
                      ),
                      if (user.phone.isNotEmpty) ...[
                        const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: Icon(
                            Icons.phone_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Phone'),
                          subtitle: Text(user.phone),
                        ),
                      ],
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: user.active ? Colors.green : Colors.red,
                        ),
                        title: const Text('Status'),
                        subtitle: Text(
                          user.active ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: user.active ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withAlpha(150),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
