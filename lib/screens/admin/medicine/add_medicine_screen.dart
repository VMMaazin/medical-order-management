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
  bool _isLoading = false;

  bool get _isEditing => widget.initialMedicine != null;

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _compositionController.dispose();
    _categoryController.dispose();
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
          name: _nameController.text,
          brand: _brandController.text,
          composition: _compositionController.text,
          category: _categoryController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine updated successfully')),
        );
        Navigator.of(context).pop();
      } else {
        final newId = await service.addMedicine(
          name: _nameController.text,
          brand: _brandController.text,
          composition: _compositionController.text,
          category: _categoryController.text,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine added. Now add dosage variants.'),
          ),
        );

        // Replace add screen with medicine details screen so admin can immediately add variants
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
                      : 'Create Parent Medicine',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Parent medicine defines name, brand, composition and category. Variants (strengths, pack sizes, prices) are added after creation.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
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

                // Brand field
                TextFormField(
                  controller: _brandController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Brand / Manufacturer *',
                    hintText: 'e.g. ABC Pharma',
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter brand/manufacturer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Composition field
                TextFormField(
                  controller: _compositionController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Composition / Generic Formula *',
                    hintText: 'e.g. Azithromycin IP',
                    prefixIcon: Icon(Icons.science_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter active composition';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category field
                TextFormField(
                  controller: _categoryController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Therapeutic Category *',
                    hintText: 'e.g. Antibiotic, Analgesic, Antacid',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter therapeutic category';
                    }
                    return null;
                  },
                ),
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
                            _isEditing ? 'Save Changes' : 'Create & Add Variants',
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
