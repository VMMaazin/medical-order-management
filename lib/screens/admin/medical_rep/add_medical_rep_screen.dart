import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medical_rep.dart';
import '../../../providers/medical_rep_provider.dart';

class AddMedicalRepScreen extends ConsumerStatefulWidget {
  final MedicalRep? initialRep;

  const AddMedicalRepScreen({
    super.key,
    this.initialRep,
  });

  @override
  ConsumerState<AddMedicalRepScreen> createState() =>
      _AddMedicalRepScreenState();
}

class _AddMedicalRepScreenState extends ConsumerState<AddMedicalRepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;

  bool get _isEditing => widget.initialRep != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialRep?.name ?? '');
    _emailController =
        TextEditingController(text: widget.initialRep?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.initialRep?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    final email = value.trim();
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
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

    final service = ref.read(medicalRepServiceProvider);

    try {
      if (_isEditing) {
        await service.updateMedicalRepProfile(
          id: widget.initialRep!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Representative profile updated successfully'),
          ),
        );
        Navigator.of(context).pop();
      } else {
        await service.createMedicalRepProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Representative profile created successfully'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save representative: $e'),
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
        title: Text(_isEditing ? 'Edit Representative' : 'Add Representative'),
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
                      ? 'Update Representative Profile'
                      : 'Create Representative Profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage medical representative profiles, contact info, and territory authorization.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Stage 1 Notice Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isEditing
                              ? 'Editing profile information in Firestore.'
                              : 'Stage 1 creates the representative profile. Login credentials will be provisioned in Stage 2.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Name field
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Rahul Sharma',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter representative name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'e.g. rahul.sharma@med.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
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
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing
                                ? 'Save Changes'
                                : 'Create Representative',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
