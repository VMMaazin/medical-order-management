import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chemist.dart';
import '../../../providers/chemist_provider.dart';
import 'add_chemist_screen.dart';

class ChemistDetailsScreen extends ConsumerWidget {
  final String chemistId;

  const ChemistDetailsScreen({
    super.key,
    required this.chemistId,
  });

  Future<void> _confirmStatusChange(
    BuildContext context,
    WidgetRef ref,
    Chemist chemist,
  ) async {
    final willDeactivate = chemist.active;
    final actionName = willDeactivate ? 'Deactivate' : 'Reactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Chemist'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${chemist.name}"? This pharmacy will not be available for new order bookings.'
              : 'Are you sure you want to reactivate "${chemist.name}"?',
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
          .read(chemistServiceProvider)
          .setChemistActiveStatus(chemist.id, !willDeactivate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chemist ${willDeactivate ? 'deactivated' : 'reactivated'} successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chemistAsync = ref.watch(singleChemistProvider(chemistId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chemist Details'),
        actions: [
          chemistAsync.when(
            data: (chemist) {
              if (chemist == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit Chemist',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddChemistScreen(
                        initialChemist: chemist,
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
        child: chemistAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error loading chemist details: $error',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (chemist) {
            if (chemist == null) {
              return const Center(
                child: Text('Chemist record not found'),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: 32,
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: chemist.active
                                      ? Colors.green.withAlpha(30)
                                      : Colors.red.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: chemist.active
                                        ? Colors.green
                                        : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  chemist.active ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: chemist.active
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            chemist.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chemist / Pharmacy Shop',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: 28),
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: chemist.phone.isNotEmpty
                                ? chemist.phone
                                : 'Not provided',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: chemist.address.isNotEmpty
                                ? chemist.address
                                : 'Not provided',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            label: 'Status',
                            value: chemist.active
                                ? 'Active (Eligible for orders)'
                                : 'Inactive (Archived)',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddChemistScreen(
                                          initialChemist: chemist,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _confirmStatusChange(
                                    context,
                                    ref,
                                    chemist,
                                  ),
                                  icon: Icon(
                                    chemist.active
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    chemist.active ? 'Deactivate' : 'Reactivate',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: chemist.active
                                        ? theme.colorScheme.error
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
