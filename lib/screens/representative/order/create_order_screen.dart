import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chemist.dart';
import '../../../models/doctor.dart';
import '../../../models/order_draft.dart';
import '../../../providers/chemist_provider.dart';
import '../../../providers/doctor_provider.dart';
import 'add_medicines_screen.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _doctorSearchController = TextEditingController();
  final TextEditingController _chemistSearchController =
      TextEditingController();

  Doctor? _selectedDoctor;
  Chemist? _selectedChemist;

  String _doctorQuery = '';
  String _chemistQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _doctorSearchController.addListener(() {
      setState(() {
        _doctorQuery = _doctorSearchController.text.trim().toLowerCase();
      });
    });

    _chemistSearchController.addListener(() {
      setState(() {
        _chemistQuery = _chemistSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _doctorSearchController.dispose();
    _chemistSearchController.dispose();
    super.dispose();
  }

  void _onDoctorSelected(Doctor doctor) {
    setState(() {
      _selectedDoctor = doctor;
    });

    // Auto-advance to Chemist selection if not already selected
    if (_selectedChemist == null && _tabController.index == 0) {
      _tabController.animateTo(1);
    }
  }

  void _onChemistSelected(Chemist chemist) {
    setState(() {
      _selectedChemist = chemist;
    });
  }

  void _onSkipDoctor() {
    setState(() {
      _selectedDoctor = const Doctor(
        id: 'skipped',
        name: 'Direct Order (No Doctor)',
        specialization: '',
        phone: '',
        active: true,
      );
    });

    // Auto-advance to Chemist tab
    if (_tabController.index == 0) {
      _tabController.animateTo(1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doctor skipped. Now select or enter a chemist.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showCustomDoctorDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final customName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Custom Doctor'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter doctor name if not available in the list:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: textController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name *',
                  hintText: 'e.g. Dr. Rajesh Kumar',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter doctor name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(textController.text.trim());
              }
            },
            child: const Text('Use Doctor'),
          ),
        ],
      ),
    );

    if (customName != null && customName.isNotEmpty) {
      setState(() {
        _selectedDoctor = Doctor(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: customName,
          specialization: 'Custom Doctor',
          phone: '',
          active: true,
        );
      });

      if (_selectedChemist == null && _tabController.index == 0) {
        _tabController.animateTo(1);
      }
    }
  }

  Future<void> _showCustomChemistDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final customName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storefront_outlined, color: Color(0xFF0284C7)),
            SizedBox(width: 8),
            Text('Custom Chemist'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter chemist or pharmacy name (no address or phone required):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: textController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Chemist Name *',
                  hintText: 'e.g. Apollo Pharmacy',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter chemist name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(textController.text.trim());
              }
            },
            child: const Text('Use Chemist'),
          ),
        ],
      ),
    );

    if (customName != null && customName.isNotEmpty) {
      setState(() {
        _selectedChemist = Chemist(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: customName,
          phone: '',
          address: '',
          active: true,
        );
      });
    }
  }

  void _onClearDoctor() {
    setState(() {
      _selectedDoctor = null;
    });
  }

  void _onClearChemist() {
    setState(() {
      _selectedChemist = null;
    });
  }

  void _handleContinueTap() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_selectedChemist == null) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a chemist to continue.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Doctor is optional. If not selected, set as Direct Order
    final effectiveDoctor = _selectedDoctor ??
        const Doctor(
          id: 'skipped',
          name: 'Direct Order (No Doctor)',
          specialization: '',
          phone: '',
          active: true,
        );

    final orderDraft = OrderDraft(
      doctor: effectiveDoctor,
      chemist: _selectedChemist!,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddMedicinesScreen(orderDraft: orderDraft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReadyToContinue = _selectedChemist != null;

    final doctorsAsync = ref.watch(activeDoctorsStreamProvider);
    final chemistsAsync = ref.watch(activeChemistsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator Header
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(100),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0D9488).withAlpha(100),
                          ),
                        ),
                        child: const Text(
                          'Step 1 of 2',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Doctor & Chemist',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Selection Status Chips
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _tabController.animateTo(0),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedDoctor != null
                                  ? const Color(0xFF0D9488).withAlpha(20)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withAlpha(80),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedDoctor != null
                                    ? const Color(0xFF0D9488)
                                    : theme.colorScheme.outlineVariant
                                        .withAlpha(120),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedDoctor != null
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: _selectedDoctor != null
                                      ? const Color(0xFF0D9488)
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedDoctor != null
                                        ? _selectedDoctor!.name
                                        : 'Doctor (Optional)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _selectedDoctor != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _selectedDoctor != null
                                          ? const Color(0xFF0F766E)
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _tabController.animateTo(1),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedChemist != null
                                  ? const Color(0xFF0284C7).withAlpha(20)
                                  : theme.colorScheme.surfaceContainerHighest
                                      .withAlpha(80),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedChemist != null
                                    ? const Color(0xFF0284C7)
                                    : theme.colorScheme.outlineVariant
                                        .withAlpha(120),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedChemist != null
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: _selectedChemist != null
                                      ? const Color(0xFF0284C7)
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _selectedChemist != null
                                        ? _selectedChemist!.name
                                        : 'Chemist required *',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _selectedChemist != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _selectedChemist != null
                                          ? const Color(0xFF0369A1)
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Bar Switcher
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF0D9488),
              labelColor: const Color(0xFF0D9488),
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(
                  icon: Icon(Icons.medical_services_outlined),
                  text: 'Select Doctor',
                ),
                Tab(
                  icon: Icon(Icons.local_pharmacy_outlined),
                  text: 'Select Chemist',
                ),
              ],
            ),

            // Tab Views: Doctor list and Chemist list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Doctor Selection
                  _DoctorSelectionTab(
                    searchController: _doctorSearchController,
                    searchQuery: _doctorQuery,
                    doctorsAsync: doctorsAsync,
                    selectedDoctor: _selectedDoctor,
                    onDoctorSelected: _onDoctorSelected,
                    onCustomDoctorPressed: _showCustomDoctorDialog,
                    onSkipDoctorPressed: _onSkipDoctor,
                    onClearDoctorPressed: _onClearDoctor,
                  ),

                  // Tab 2: Chemist Selection
                  _ChemistSelectionTab(
                    searchController: _chemistSearchController,
                    searchQuery: _chemistQuery,
                    chemistsAsync: chemistsAsync,
                    selectedChemist: _selectedChemist,
                    onChemistSelected: _onChemistSelected,
                    onCustomChemistPressed: _showCustomChemistDialog,
                    onClearChemistPressed: _onClearChemist,
                  ),
                ],
              ),
            ),

            // Bottom Continue Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(100),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleContinueTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReadyToContinue
                          ? const Color(0xFF0D9488)
                          : theme.colorScheme.surfaceContainerHighest
                              .withAlpha(160),
                      foregroundColor: isReadyToContinue
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant.withAlpha(160),
                      elevation: isReadyToContinue ? 1 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isReadyToContinue
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant
                                    .withAlpha(160),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: isReadyToContinue
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant
                                  .withAlpha(160),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorSelectionTab extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final AsyncValue<List<Doctor>> doctorsAsync;
  final Doctor? selectedDoctor;
  final ValueChanged<Doctor> onDoctorSelected;
  final VoidCallback onCustomDoctorPressed;
  final VoidCallback onSkipDoctorPressed;
  final VoidCallback onClearDoctorPressed;

  const _DoctorSelectionTab({
    required this.searchController,
    required this.searchQuery,
    required this.doctorsAsync,
    required this.selectedDoctor,
    required this.onDoctorSelected,
    required this.onCustomDoctorPressed,
    required this.onSkipDoctorPressed,
    required this.onClearDoctorPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom Doctor & Skip Doctor Options at the top
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCustomDoctorPressed,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Custom Doctor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D9488),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSkipDoctorPressed,
                  icon: const Icon(Icons.skip_next_outlined, size: 18),
                  label: const Text('Skip Doctor',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                    side: BorderSide(color: Colors.orange.shade400),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selected Doctor Banner (if selected or skipped)
        if (selectedDoctor != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFF0D9488).withAlpha(120)),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedDoctor!.id.startsWith('custom')
                        ? Icons.person_outline
                        : (selectedDoctor!.id == 'skipped'
                            ? Icons.skip_next
                            : Icons.check_circle),
                    color: const Color(0xFF0D9488),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDoctor!.id.startsWith('custom')
                              ? 'Custom Doctor Selected'
                              : (selectedDoctor!.id == 'skipped'
                                  ? 'Doctor Skipped (Direct Order)'
                                  : 'Doctor Selected'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                        Text(
                          selectedDoctor!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onClearDoctorPressed,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

        // Doctor Search Box
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search doctors...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: searchController.clear,
                    )
                  : null,
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(120),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Doctors List
        Expanded(
          child: doctorsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Failed to load doctors: $err'),
              ),
            ),
            data: (allDoctors) {
              // Ensure only ACTIVE doctors are displayed
              final activeDoctors =
                  allDoctors.where((doc) => doc.active).toList();

              if (activeDoctors.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No active doctors available.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Apply search filter (name, specialization, phone)
              final filteredDoctors = activeDoctors.where((doc) {
                if (searchQuery.isEmpty) return true;
                return doc.name.toLowerCase().contains(searchQuery) ||
                    doc.specialization.toLowerCase().contains(searchQuery) ||
                    doc.phone.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredDoctors.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No doctors found.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                itemCount: filteredDoctors.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  final isSelected = selectedDoctor?.id == doctor.id;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : theme.colorScheme.outlineVariant.withAlpha(128),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    color: isSelected
                        ? const Color(0xFF0D9488).withAlpha(18)
                        : theme.colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onDoctorSelected(doctor),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0D9488)
                                    : const Color(0xFF0D9488).withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.medical_services_outlined,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0D9488),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.name,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF0F766E)
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (doctor.specialization.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialization,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF0D9488),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  if (doctor.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_outlined,
                                          size: 14,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          doctor.phone,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                color: theme.colorScheme.outlineVariant,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ChemistSelectionTab extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final AsyncValue<List<Chemist>> chemistsAsync;
  final Chemist? selectedChemist;
  final ValueChanged<Chemist> onChemistSelected;
  final VoidCallback onCustomChemistPressed;
  final VoidCallback onClearChemistPressed;

  const _ChemistSelectionTab({
    required this.searchController,
    required this.searchQuery,
    required this.chemistsAsync,
    required this.selectedChemist,
    required this.onChemistSelected,
    required this.onCustomChemistPressed,
    required this.onClearChemistPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom Chemist Option at the top
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCustomChemistPressed,
              icon: const Icon(Icons.add_business_outlined, size: 18),
              label: const Text(
                'Chemist not in list? Enter Custom Chemist',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0284C7),
                side: const BorderSide(color: Color(0xFF0284C7)),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),

        // Selected Chemist Banner (if selected)
        if (selectedChemist != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFF0284C7).withAlpha(120)),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedChemist!.id.startsWith('custom')
                        ? Icons.storefront_outlined
                        : Icons.check_circle,
                    color: const Color(0xFF0284C7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedChemist!.id.startsWith('custom')
                              ? 'Custom Chemist Selected'
                              : 'Chemist Selected',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                        Text(
                          selectedChemist!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onClearChemistPressed,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

        // Chemist Search Box
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search chemists...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: searchController.clear,
                    )
                  : null,
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(120),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Chemists List
        Expanded(
          child: chemistsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Failed to load chemists: $err'),
              ),
            ),
            data: (allChemists) {
              // Ensure only ACTIVE chemists are displayed
              final activeChemists =
                  allChemists.where((ch) => ch.active).toList();

              if (activeChemists.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No active chemists available.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Apply search filter (name, phone, address)
              final filteredChemists = activeChemists.where((ch) {
                if (searchQuery.isEmpty) return true;
                return ch.name.toLowerCase().contains(searchQuery) ||
                    ch.phone.toLowerCase().contains(searchQuery) ||
                    ch.address.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredChemists.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No chemists found.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                itemCount: filteredChemists.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final chemist = filteredChemists[index];
                  final isSelected = selectedChemist?.id == chemist.id;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0284C7)
                            : theme.colorScheme.outlineVariant.withAlpha(128),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    color: isSelected
                        ? const Color(0xFF0284C7).withAlpha(18)
                        : theme.colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onChemistSelected(chemist),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF0284C7).withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.local_pharmacy_outlined,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF0284C7),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chemist.name,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFF0369A1)
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (chemist.address.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      chemist.address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  if (chemist.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone_outlined,
                                          size: 14,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          chemist.phone,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              )
                            else
                              Icon(
                                Icons.radio_button_unchecked,
                                color: theme.colorScheme.outlineVariant,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
