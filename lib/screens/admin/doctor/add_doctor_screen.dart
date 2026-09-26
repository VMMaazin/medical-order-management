import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/doctor.dart';
import '../../../providers/doctor_provider.dart';

class AddDoctorScreen extends ConsumerStatefulWidget {
  final Doctor? initialDoctor;

  const AddDoctorScreen({
    super.key,
    this.initialDoctor,
  });

  @override
  ConsumerState<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends ConsumerState<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _specializationController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  bool get _isEditing => widget.initialDoctor != null;

  static const List<String> _commonSpecializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
    'Gynecologist',
    'ENT Specialist',
    'Neurologist',
    'Ophthalmologist',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialDoctor?.name ?? '');
    _specializationController =
        TextEditingController(text: widget.initialDoctor?.specialization ?? '');
    _phoneController =
        TextEditingController(text: widget.initialDoctor?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final regex = RegExp(r'^(?:(?:\+?91)|0)?[6-9]\d{9}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final service = ref.read(doctorServiceProvider);

    try {
      if (_isEditing) {
        await service.updateDoctor(
          id: widget.initialDoctor!.id,
          name: _nameController.text.trim(),
          specialization: _specializationController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor profile updated successfully')),
        );
        Navigator.of(context).pop();
      } else {
        await service.addDoctor(
          name: _nameController.text.trim(),
          specialization: _specializationController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save doctor: $e'),
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
        title: Text(_isEditing ? 'Edit Doctor' : 'Add Doctor'),
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
                  _isEditing ? 'Update Doctor Details' : 'Register New Doctor',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Maintain accurate medical practitioner records for field representatives when taking orders.',
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
                    labelText: 'Doctor Name *',
                    hintText: 'e.g. Dr. Rajesh Kumar',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Specialization field
                TextFormField(
                  controller: _specializationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Specialization *',
                    hintText: 'e.g. Cardiologist, General Physician',
                    prefixIcon: Icon(Icons.medical_information_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter doctor specialization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Specialization quick chips
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _commonSpecializations.take(5).map((spec) {
                    return ActionChip(
                      label: Text(spec),
                      labelStyle: const TextStyle(fontSize: 12),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _specializationController.text = spec;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Phone field (optional)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'e.g. +91 9876543210 or 9876543210',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePhone,
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
                            _isEditing ? 'Save Changes' : 'Add Doctor',
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
