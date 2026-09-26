import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medical_rep.dart';
import '../../../providers/medical_rep_provider.dart';
import 'add_medical_rep_screen.dart';

class MedicalRepDetailsScreen extends ConsumerWidget {
  final String repId;

  const MedicalRepDetailsScreen({
    super.key,
    required this.repId,
  });

  Future<void> _confirmStatusChange(
    BuildContext context,
    WidgetRef ref,
    MedicalRep rep,
  ) async {
    final willDeactivate = rep.active;
    final actionName = willDeactivate ? 'Deactivate' : 'Reactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Representative'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${rep.name}"? This representative will not be able to log in or book orders.'
              : 'Are you sure you want to reactivate "${rep.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: willDeactivate
                  ? Theme.of(ctx).colorScheme.error
                  : Theme.of(ctx).colorScheme.primary,
              foregroundColor: willDeactivate
                  ? Theme.of(ctx).colorScheme.onError
                  : Theme.of(ctx).colorScheme.onPrimary,
            ),
            child: Text(actionName),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(medicalRepServiceProvider)
          .setMedicalRepActiveStatus(rep.id, !willDeactivate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Representative ${willDeactivate ? 'deactivated' : 'reactivated'} successfully',
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repAsync = ref.watch(singleMedicalRepProvider(repId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Representative Details'),
        actions: [
          repAsync.when(
            data: (rep) {
              if (rep == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit Representative',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMedicalRepScreen(
                        initialRep: rep,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: repAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error loading representative details: $error',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (rep) {
            if (rep == null) {
              return const Center(
                child: Text('Representative record not found'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
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
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF7C3AED)
                                    .withAlpha(30),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF7C3AED),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rep.name,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED)
                                            .withAlpha(25),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Medical Representative',
                                        style: TextStyle(
                                          color: Color(0xFF7C3AED),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: rep.active
                                      ? const Color(0xFF10B981).withAlpha(30)
                                      : Colors.grey.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: rep.active
                                        ? const Color(0xFF10B981)
                                        : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  rep.active ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: rep.active
                                        ? const Color(0xFF047857)
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),

                          // Contact Info List
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: rep.email,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: rep.phone,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            label: 'Role',
                            value: rep.role,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Created',
                            value: _formatDate(rep.createdAt),
                          ),
                          if (rep.updatedAt != null) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.update_outlined,
                              label: 'Last Updated',
                              value: _formatDate(rep.updatedAt),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Auth Linkage Notice
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Firebase Auth Account Linked',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'UID: ${rep.id}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMedicalRepScreen(
                                  initialRep: rep,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _confirmStatusChange(context, ref, rep),
                          icon: Icon(
                            rep.active
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                          ),
                          label: Text(
                            rep.active ? 'Deactivate' : 'Reactivate',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rep.active
                                ? theme.colorScheme.errorContainer
                                : theme.colorScheme.primaryContainer,
                            foregroundColor: rep.active
                                ? theme.colorScheme.onErrorContainer
                                : theme.colorScheme.onPrimaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
