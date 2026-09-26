import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/doctor.dart';
import '../../../providers/doctor_provider.dart';
import 'add_doctor_screen.dart';

class DoctorDetailsScreen extends ConsumerWidget {
  final String doctorId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
  });

  Future<void> _confirmStatusChange(
    BuildContext context,
    WidgetRef ref,
    Doctor doctor,
  ) async {
    final willDeactivate = doctor.active;
    final actionName = willDeactivate ? 'Deactivate' : 'Reactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Doctor'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${doctor.name}"? This doctor will not be available for selection in new orders.'
              : 'Are you sure you want to reactivate "${doctor.name}"?',
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
          .read(doctorServiceProvider)
          .setDoctorActiveStatus(doctor.id, !willDeactivate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Doctor ${willDeactivate ? 'deactivated' : 'reactivated'} successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final doctorAsync = ref.watch(singleDoctorProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        actions: [
          doctorAsync.when(
            data: (doctor) {
              if (doctor == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit Doctor',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddDoctorScreen(
                        initialDoctor: doctor,
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
        child: doctorAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error loading doctor profile: $error',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (doctor) {
            if (doctor == null) {
              return const Center(
                child: Text('Doctor record not found'),
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
                                  Icons.medical_information_outlined,
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
                                  color: doctor.active
                                      ? Colors.green.withAlpha(30)
                                      : Colors.red.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: doctor.active
                                        ? Colors.green
                                        : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  doctor.active ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: doctor.active
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
                            doctor.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialization,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: 28),
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: doctor.phone.isNotEmpty
                                ? doctor.phone
                                : 'Not provided',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.badge_outlined,
                            label: 'Status',
                            value: doctor.active
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
                                        builder: (_) => AddDoctorScreen(
                                          initialDoctor: doctor,
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
                                    doctor,
                                  ),
                                  icon: Icon(
                                    doctor.active
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    doctor.active ? 'Deactivate' : 'Reactivate',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: doctor.active
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
