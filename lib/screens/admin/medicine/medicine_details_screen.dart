import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medicine.dart';
import '../../../models/medicine_variant.dart';
import '../../../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';
import 'add_variant_dialog.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  final String medicineId;

  const MedicineDetailsScreen({
    super.key,
    required this.medicineId,
  });

  void _showAddEditVariantDialog(
    BuildContext context, {
    MedicineVariant? variant,
  }) {
    showDialog(
      context: context,
      builder: (_) => AddVariantDialog(
        medicineId: medicineId,
        initialVariant: variant,
      ),
    );
  }

  Future<void> _confirmMedicineStatusChange(
    BuildContext context,
    WidgetRef ref,
    Medicine medicine,
  ) async {
    final willDeactivate = medicine.active;
    final actionName = willDeactivate ? 'Deactivate' : 'Activate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Medicine'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${medicine.name}"? It will not appear in the active ordering list.'
              : 'Are you sure you want to reactivate "${medicine.name}"?',
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
          .read(medicineServiceProvider)
          .setMedicineActiveStatus(medicine.id, !willDeactivate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Medicine ${willDeactivate ? 'deactivated' : 'reactivated'} successfully',
          ),
        ),
      );
    }
  }

  Future<void> _confirmVariantStatusChange(
    BuildContext context,
    WidgetRef ref,
    MedicineVariant variant,
  ) async {
    final willDeactivate = variant.active;
    final actionName = willDeactivate ? 'Deactivate' : 'Activate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName Variant'),
        content: Text(
          willDeactivate
              ? 'Are you sure you want to deactivate "${variant.form} ${variant.strength}"?'
              : 'Are you sure you want to reactivate this variant?',
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
          .read(medicineServiceProvider)
          .setVariantActiveStatus(variant.id, !willDeactivate);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Variant ${willDeactivate ? 'deactivated' : 'reactivated'} successfully',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final medicineAsync = ref.watch(singleMedicineProvider(medicineId));
    final variantsAsync = ref.watch(medicineVariantsProvider(medicineId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          medicineAsync.when(
            data: (medicine) {
              if (medicine == null) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Edit Medicine',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMedicineScreen(
                        initialMedicine: medicine,
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
        child: medicineAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error loading medicine: $error',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (medicine) {
            if (medicine == null) {
              return const Center(
                child: Text('Medicine record not found'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Information Card
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      medicine.brand,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
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
                                  color: medicine.active
                                      ? Colors.green.withAlpha(30)
                                      : Colors.red.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: medicine.active
                                        ? Colors.green
                                        : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  medicine.active ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: medicine.active
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
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Composition',
                            value: medicine.composition,
                            icon: Icons.science_outlined,
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            label: 'Category',
                            value: medicine.category,
                            icon: Icons.category_outlined,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddMedicineScreen(
                                          initialMedicine: medicine,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Edit Details'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _confirmMedicineStatusChange(
                                    context,
                                    ref,
                                    medicine,
                                  ),
                                  icon: Icon(
                                    medicine.active
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: Text(
                                    medicine.active ? 'Deactivate' : 'Reactivate',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: medicine.active
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
                  const SizedBox(height: 28),

                  // Variants Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Variants',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Strengths, packaging & prices',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditVariantDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Variant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Variants List
                  variantsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(
                      'Error loading variants: $error',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    data: (variants) {
                      if (variants.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withAlpha(128),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 48,
                                color: theme.colorScheme.primary.withAlpha(150),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No variants added yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add at least one strength and packaging variant so this medicine can be ordered.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showAddEditVariantDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Variant'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: variants.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final variant = variants[index];
                          return _VariantCard(
                            variant: variant,
                            onEdit: () => _showAddEditVariantDialog(
                              context,
                              variant: variant,
                            ),
                            onToggleStatus: () => _confirmVariantStatusChange(
                              context,
                              ref,
                              variant,
                            ),
                          );
                        },
                      );
                    },
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
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
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
          width: 100,
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

class _VariantCard extends StatelessWidget {
  final MedicineVariant variant;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const _VariantCard({
    required this.variant,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        variant.form,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      variant.strength,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: variant.active
                        ? Colors.green.withAlpha(25)
                        : Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    variant.active ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: variant.active ? Colors.green.shade800 : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pack Size: ${variant.packSize}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MRP',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '₹${variant.mrp.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier Price',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '₹${variant.supplierPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    variant.active ? Icons.block : Icons.check,
                    size: 16,
                  ),
                  label: Text(variant.active ? 'Deactivate' : 'Activate'),
                  style: TextButton.styleFrom(
                    foregroundColor: variant.active
                        ? theme.colorScheme.error
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
