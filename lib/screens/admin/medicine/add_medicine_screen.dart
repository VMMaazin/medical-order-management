import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medicine.dart';
import '../../../providers/medicine_provider.dart';
import 'medicine_details_screen.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  final Medicine? initialMedicine;

  const AddMedicineScreen({
    super.key,
    this.initialMedicine,
  });

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _compositionController;
  late final TextEditingController _categoryController;

  // Initial variant fields (created automatically with medicine by default)
  bool _createInitialVariant = true;
  late final TextEditingController _variantFormController;
  late final TextEditingController _variantStrengthController;
  late final TextEditingController _variantPackSizeController;
  late final TextEditingController _variantMrpController;
  late final TextEditingController _variantSupplierPriceController;

  bool _isLoading = false;

  bool get _isEditing => widget.initialMedicine != null;

  static const List<String> _commonForms = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Suspension',
    'Injection',
    'Ointment',
    'Cream',
    'Gel',
    'Drops',
    'Inhaler',
    'Powder',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialMedicine?.name ?? '');
    _brandController =
        TextEditingController(text: widget.initialMedicine?.brand ?? '');
    _compositionController =
        TextEditingController(text: widget.initialMedicine?.composition ?? '');
    _categoryController =
        TextEditingController(text: widget.initialMedicine?.category ?? '');

    _variantFormController = TextEditingController(text: 'Tablet');
    _variantStrengthController = TextEditingController();
    _variantPackSizeController = TextEditingController(text: '1x10');
    _variantMrpController = TextEditingController();
    _variantSupplierPriceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _compositionController.dispose();
    _categoryController.dispose();

    _variantFormController.dispose();
    _variantStrengthController.dispose();
    _variantPackSizeController.dispose();
    _variantMrpController.dispose();
    _variantSupplierPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final service = ref.read(medicineServiceProvider);

    try {
      if (_isEditing) {
        await service.updateMedicine(
          id: widget.initialMedicine!.id,
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          composition: _compositionController.text.trim(),
          category: _categoryController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine updated successfully')),
        );
        Navigator.of(context).pop();
      } else {
        final newId = await service.addMedicine(
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          composition: _compositionController.text.trim(),
          category: _categoryController.text.trim(),
        );

        // If initial variant is enabled and MRP/SupplierPrice are provided, create it immediately
        if (_createInitialVariant) {
          final mrp = double.tryParse(_variantMrpController.text.trim()) ?? 0.0;
          final supplierPrice =
              double.tryParse(_variantSupplierPriceController.text.trim()) ?? 0.0;

          await service.addVariant(
            medicineId: newId,
            form: _variantFormController.text.trim().isEmpty
                ? 'Tablet'
                : _variantFormController.text.trim(),
            strength: _variantStrengthController.text.trim(),
            packSize: _variantPackSizeController.text.trim().isEmpty
                ? '1x10'
                : _variantPackSizeController.text.trim(),
            mrp: mrp,
            supplierPrice: supplierPrice,
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _createInitialVariant
                  ? 'Medicine and initial variant created successfully'
                  : 'Medicine created successfully',
            ),
          ),
        );

        // Navigate to details screen so admin can view/manage variants
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MedicineDetailsScreen(medicineId: newId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save medicine: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing
                      ? 'Update Medicine Information'
                      : 'Create Medicine',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditing
                      ? 'Update general details of this medicine.'
                      : 'Enter medicine details. Only medicine name is required. You can also configure the first variant below.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Name field (REQUIRED)
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name *',
                    hintText: 'e.g. Azithromycin',
                    prefixIcon: Icon(Icons.medication_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Brand field (OPTIONAL)
                TextFormField(
                  controller: _brandController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Brand / Manufacturer (Optional)',
                    hintText: 'e.g. ABC Pharma',
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Composition field (OPTIONAL)
                TextFormField(
                  controller: _compositionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Composition / Generic Formula (Optional)',
                    hintText: 'e.g. Azithromycin IP',
                    prefixIcon: Icon(Icons.science_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Category field (OPTIONAL)
                TextFormField(
                  controller: _categoryController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Therapeutic Category (Optional)',
                    hintText: 'e.g. Antibiotic, Analgesic, Antacid',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                // Initial Variant Section (Only when creating new medicine)
                if (!_isEditing) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _createInitialVariant
                            ? theme.colorScheme.primary.withAlpha(120)
                            : theme.colorScheme.outlineVariant.withAlpha(100),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.layers_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Initial Variant',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _createInitialVariant,
                              onChanged: (val) {
                                setState(() {
                                  _createInitialVariant = val;
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          'Creates the first variant automatically. You can add more variants later.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_createInitialVariant) ...[
                          const SizedBox(height: 16),
                          // Dosage form dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _variantFormController.text.isNotEmpty
                                ? _variantFormController.text
                                : 'Tablet',
                            decoration: const InputDecoration(
                              labelText: 'Dosage Form *',
                              prefixIcon: Icon(Icons.local_pharmacy_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: _commonForms.map((form) {
                              return DropdownMenuItem(
                                value: form,
                                child: Text(form),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _variantFormController.text = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // Strength & Pack Size Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _variantStrengthController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Strength',
                                    hintText: 'e.g. 500 mg',
                                    prefixIcon: Icon(Icons.fitness_center_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _variantPackSizeController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Pack Size',
                                    hintText: 'e.g. 10 Tablets',
                                    prefixIcon: Icon(Icons.inventory_2_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // MRP and Supplier Price Row
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _variantMrpController,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'MRP (₹) *',
                                    hintText: 'e.g. 100.00',
                                    prefixIcon: Icon(Icons.currency_rupee),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (!_createInitialVariant || _isEditing) {
                                      return null;
                                    }
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter MRP';
                                    }
                                    final parsed = double.tryParse(value.trim());
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter valid MRP (> 0)';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _variantSupplierPriceController,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: 'Supplier Price (₹) *',
                                    hintText: 'e.g. 75.00',
                                    prefixIcon: Icon(Icons.price_check),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (!_createInitialVariant || _isEditing) {
                                      return null;
                                    }
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter supplier price';
                                    }
                                    final parsed = double.tryParse(value.trim());
                                    if (parsed == null || parsed < 0) {
                                      return 'Enter valid price (>= 0)';
                                    }
                                    final mrp = double.tryParse(
                                        _variantMrpController.text.trim());
                                    if (mrp != null && parsed > mrp) {
                                      return 'Cannot exceed MRP';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            _isEditing
                                ? 'Save Changes'
                                : (_createInitialVariant
                                    ? 'Create Medicine & Variant'
                                    : 'Create Medicine'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
