import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medicine_variant.dart';
import '../../../providers/medicine_provider.dart';

class AddVariantDialog extends ConsumerStatefulWidget {
  final String medicineId;
  final MedicineVariant? initialVariant;

  const AddVariantDialog({
    super.key,
    required this.medicineId,
    this.initialVariant,
  });

  @override
  ConsumerState<AddVariantDialog> createState() => _AddVariantDialogState();
}

class _AddVariantDialogState extends ConsumerState<AddVariantDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _formController;
  late final TextEditingController _strengthController;
  late final TextEditingController _packSizeController;
  late final TextEditingController _mrpController;
  late final TextEditingController _supplierPriceController;
  bool _isLoading = false;

  bool get _isEditing => widget.initialVariant != null;

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
    _formController =
        TextEditingController(text: widget.initialVariant?.form ?? 'Tablet');
    _strengthController =
        TextEditingController(text: widget.initialVariant?.strength ?? '');
    _packSizeController =
        TextEditingController(text: widget.initialVariant?.packSize ?? '');
    _mrpController = TextEditingController(
      text: widget.initialVariant != null
          ? widget.initialVariant!.mrp.toStringAsFixed(2)
          : '',
    );
    _supplierPriceController = TextEditingController(
      text: widget.initialVariant != null
          ? widget.initialVariant!.supplierPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    _strengthController.dispose();
    _packSizeController.dispose();
    _mrpController.dispose();
    _supplierPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final mrp = double.parse(_mrpController.text.trim());
    final supplierPrice = double.parse(_supplierPriceController.text.trim());
    final service = ref.read(medicineServiceProvider);

    try {
      if (_isEditing) {
        await service.updateVariant(
          id: widget.initialVariant!.id,
          form: _formController.text.trim(),
          strength: _strengthController.text.trim(),
          packSize: _packSizeController.text.trim(),
          mrp: mrp,
          supplierPrice: supplierPrice,
        );

        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variant updated successfully')),
        );
      } else {
        await service.addVariant(
          medicineId: widget.medicineId,
          form: _formController.text.trim(),
          strength: _strengthController.text.trim(),
          packSize: _packSizeController.text.trim(),
          mrp: mrp,
          supplierPrice: supplierPrice,
        );

        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Variant added successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save variant: $e'),
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

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Variant' : 'Add Medicine Variant'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form field with common form chips
                TextFormField(
                  controller: _formController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Form *',
                    hintText: 'e.g. Tablet, Capsule, Syrup',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify the dosage form';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _commonForms.take(4).map((f) {
                    return ActionChip(
                      label: Text(f),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _formController.text = f;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Strength
                TextFormField(
                  controller: _strengthController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Strength *',
                    hintText: 'e.g. 500 mg, 250 mg/5ml',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter strength';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pack Size
                TextFormField(
                  controller: _packSizeController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Pack Size *',
                    hintText: 'e.g. 10 tablets, 100 ml bottle',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter pack size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // MRP and Supplier Price in a Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mrpController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'MRP (₹) *',
                          hintText: '120.00',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter MRP';
                          }
                          final num = double.tryParse(value.trim());
                          if (num == null || num <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _supplierPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Supplier Price (₹) *',
                          hintText: '90.00',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter price';
                          }
                          final supplier = double.tryParse(value.trim());
                          if (supplier == null || supplier <= 0) {
                            return 'Must be > 0';
                          }
                          final mrp = double.tryParse(_mrpController.text.trim());
                          if (mrp != null && supplier > mrp) {
                            return 'Cannot exceed MRP';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save' : 'Add Variant'),
        ),
      ],
    );
  }
}
