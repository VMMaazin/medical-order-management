import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medicine.dart';
import '../../../models/medicine_variant.dart';
import '../../../models/order_draft.dart';
import '../../../models/order_draft_item.dart';
import '../../../providers/medicine_provider.dart';
import 'review_order_screen.dart';

class AddMedicinesScreen extends ConsumerStatefulWidget {
  final OrderDraft orderDraft;

  const AddMedicinesScreen({
    super.key,
    required this.orderDraft,
  });

  @override
  ConsumerState<AddMedicinesScreen> createState() => _AddMedicinesScreenState();
}

class _AddMedicinesScreenState extends ConsumerState<AddMedicinesScreen> {
  late OrderDraft _currentDraft;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentDraft = widget.orderDraft;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart({
    required Medicine medicine,
    required MedicineVariant variant,
    required int quantity,
  }) {
    if (quantity < 1) return;

    final existingIndex = _currentDraft.items.indexWhere(
      (item) => item.variantId == variant.id,
    );

    List<OrderDraftItem> updatedItems = List.from(_currentDraft.items);

    if (existingIndex >= 0) {
      // If the exact same variant is added again, increase existing quantity
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Create new snapshot item for this variant
      final newItem = OrderDraftItem(
        medicineId: medicine.id,
        medicineName: medicine.name,
        brand: medicine.brand,
        composition: medicine.composition,
        variantId: variant.id,
        form: variant.form,
        strength: variant.strength,
        packSize: variant.packSize,
        mrp: variant.mrp,
        supplierPrice: variant.supplierPrice,
        quantity: quantity,
      );
      updatedItems.add(newItem);
    }

    setState(() {
      _currentDraft = _currentDraft.copyWith(items: updatedItems);
    });
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;

    final updatedItems = List<OrderDraftItem>.from(_currentDraft.items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: newQuantity);

    setState(() {
      _currentDraft = _currentDraft.copyWith(items: updatedItems);
    });
  }

  void _removeItem(int index) {
    final updatedItems = List<OrderDraftItem>.from(_currentDraft.items)
      ..removeAt(index);

    setState(() {
      _currentDraft = _currentDraft.copyWith(items: updatedItems);
    });
  }

  void _openVariantSelectionModal(BuildContext context, Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _VariantSelectionModal(
          medicine: medicine,
          onAddToCart: (variant, quantity) {
            _addToCart(
              medicine: medicine,
              variant: variant,
              quantity: quantity,
            );
          },
        );
      },
    );
  }

  Future<void> _showCustomMedicineDialog({String? initialName}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: initialName ?? (_searchQuery.isNotEmpty ? _searchController.text.trim() : ''),
    );
    final quantityController = TextEditingController(text: '1');
    final brandController = TextEditingController();
    final compositionController = TextEditingController();
    final sellingPriceController = TextEditingController();
    final mrpController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.medication_liquid_outlined, color: Color(0xFF0D9488)),
            SizedBox(width: 8),
            Text('Add Custom Medicine'),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0D9488).withAlpha(60),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFF0D9488)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Name and Quantity are required. Other fields are optional.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. Medicine Name *
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name *',
                      hintText: 'e.g. Paracetamol 650',
                      prefixIcon: Icon(Icons.medication_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. Quantity *
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Quantity (units) *',
                      hintText: 'e.g. 10',
                      prefixIcon: Icon(Icons.numbers_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      final n = int.tryParse(val.trim());
                      if (n == null || n < 1) {
                        return 'Quantity must be at least 1';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. Brand & Composition (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: brandController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Brand (Optional)',
                            hintText: 'e.g. Cipla',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: compositionController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Composition (Optional)',
                            hintText: 'e.g. Paracetamol',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Selling / Supplier Price & MRP (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: sellingPriceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Selling Price ₹ (Optional)',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final p = double.tryParse(val.trim());
                              if (p == null || p < 0) return 'Invalid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: mrpController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'MRP ₹ (Optional)',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              final p = double.tryParse(val.trim());
                              if (p == null || p < 0) return 'Invalid MRP';
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );

    if (added == true) {
      final name = nameController.text.trim();
      final qty = int.tryParse(quantityController.text.trim()) ?? 1;
      final brand = brandController.text.trim();
      final composition = compositionController.text.trim();
      final sellingPrice =
          double.tryParse(sellingPriceController.text.trim()) ?? 0.0;
      final mrp = double.tryParse(mrpController.text.trim()) ??
          (sellingPrice > 0 ? sellingPrice : 0.0);
      final effectiveSellingPrice = sellingPrice > 0 ? sellingPrice : mrp;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final customItem = OrderDraftItem(
        medicineId: 'custom_$timestamp',
        medicineName: name,
        brand: brand.isNotEmpty ? brand : 'Custom',
        composition: composition,
        variantId: 'custom_var_$timestamp',
        form: 'Custom',
        strength: '',
        packSize: '1 unit',
        mrp: mrp,
        supplierPrice: effectiveSellingPrice,
        quantity: qty,
        isCustom: true,
      );

      final updatedItems = List<OrderDraftItem>.from(_currentDraft.items);
      final existingIndex = updatedItems.indexWhere(
        (item) =>
            item.isCustom &&
            item.medicineName.toLowerCase() == name.toLowerCase(),
      );

      if (existingIndex >= 0) {
        final existing = updatedItems[existingIndex];
        updatedItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + qty,
          supplierPrice: effectiveSellingPrice > 0
              ? effectiveSellingPrice
              : existing.supplierPrice,
          mrp: mrp > 0 ? mrp : existing.mrp,
          brand: brand.isNotEmpty ? brand : existing.brand,
          composition:
              composition.isNotEmpty ? composition : existing.composition,
        );
      } else {
        updatedItems.add(customItem);
      }

      setState(() {
        _currentDraft = _currentDraft.copyWith(items: updatedItems);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Custom medicine "$name" added to cart.'),
            backgroundColor: const Color(0xFF0D9488),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToReviewOrder() {
    if (_currentDraft.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one medicine before reviewing the order.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewOrderScreen(orderDraft: _currentDraft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicinesAsync = ref.watch(activeMedicinesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicines'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Order Context Bar (Doctor & Chemist details)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              color: const Color(0xFF0D9488).withAlpha(15),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          size: 16,
                          color: Color(0xFF0D9488),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _currentDraft.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 16,
                    width: 1,
                    color: const Color(0xFF0D9488).withAlpha(80),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_pharmacy_outlined,
                          size: 16,
                          color: Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _currentDraft.chemistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Medicines TextField
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search medicines...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: _searchController.clear,
                              )
                            : null,
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                theme.colorScheme.outlineVariant.withAlpha(120),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medicines Header & Custom Medicine Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medicines Catalog',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showCustomMedicineDialog(),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text('Add Custom Medicine'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0D9488),
                            side: const BorderSide(color: Color(0xFF0D9488)),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Medicines List
                    medicinesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Failed to load medicines: $err'),
                      ),
                      data: (allMeds) {
                        final activeMeds =
                            allMeds.where((m) => m.active).toList();

                        if (activeMeds.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withAlpha(100),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.medication_outlined,
                                    size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                const Text(
                                  'No active medicines available.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _showCustomMedicineDialog(),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Custom Medicine'),
                                ),
                              ],
                            ),
                          );
                        }

                        final filteredMeds = activeMeds.where((m) {
                          if (_searchQuery.isEmpty) return true;
                          return m.name.toLowerCase().contains(_searchQuery) ||
                              m.brand.toLowerCase().contains(_searchQuery) ||
                              m.composition
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              m.category.toLowerCase().contains(_searchQuery);
                        }).toList();

                        if (filteredMeds.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withAlpha(100),
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                const Text(
                                  'No medicines found.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _showCustomMedicineDialog(
                                    initialName: _searchController.text.trim(),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add as Custom Medicine'),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredMeds.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final medicine = filteredMeds[index];

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withAlpha(128),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _openVariantSelectionModal(
                                    context, medicine),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D9488)
                                              .withAlpha(20),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.medication_rounded,
                                          color: Color(0xFF0D9488),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medicine.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${medicine.brand} • ${medicine.category}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: const Color(0xFF0D9488),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              medicine.composition,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _openVariantSelectionModal(
                                                context, medicine),
                                        icon: const Icon(Icons.tune_rounded, size: 16),
                                        label: const Text('Variants'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF0D9488),
                                          side: const BorderSide(
                                            color: Color(0xFF0D9488),
                                          ),
                                          visualDensity:
                                              VisualDensity.compact,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
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

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Cart Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cart (${_currentDraft.totalItems} items)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentDraft.isNotEmpty)
                          Text(
                            '${_currentDraft.totalQuantity} units',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cart Items List / Empty Cart State
                    if (_currentDraft.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                theme.colorScheme.outlineVariant.withAlpha(100),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 40,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Cart is empty.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select medicines and variants above to add items.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentDraft.items.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _currentDraft.items[index];

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: const Color(0xFF0D9488).withAlpha(80),
                              ),
                            ),
                            color: const Color(0xFF0D9488).withAlpha(8),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: Name, Item Total, and Remove Button
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.medicineName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                if (item.isCustom)
                                                  Container(
                                                    margin: const EdgeInsets.only(
                                                        left: 6, right: 8),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0D9488)
                                                          .withAlpha(25),
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: const Color(0xFF0D9488),
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'CUSTOM',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0D9488),
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.isCustom
                                                  ? ([
                                                      if (item.brand.isNotEmpty &&
                                                          item.brand != 'Custom')
                                                        item.brand,
                                                      if (item.composition.isNotEmpty)
                                                        item.composition,
                                                      if (item.mrp > 0)
                                                        'MRP: ₹${item.mrp.toStringAsFixed(2)}',
                                                    ].isNotEmpty
                                                      ? [
                                                          if (item.brand.isNotEmpty &&
                                                              item.brand != 'Custom')
                                                            item.brand,
                                                          if (item.composition.isNotEmpty)
                                                            item.composition,
                                                          if (item.mrp > 0)
                                                            'MRP: ₹${item.mrp.toStringAsFixed(2)}',
                                                        ].join(' • ')
                                                      : 'Custom Item')
                                                  : '${item.form} • ${item.strength} • ${item.packSize}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${item.itemTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF0F766E),
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20,
                                              color: Colors.redAccent,
                                            ),
                                            onPressed: () => _removeItem(index),
                                            tooltip: 'Remove Item',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Row 2: Supplier Price calculation & Quantity Controls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.supplierPrice > 0
                                            ? '₹${item.supplierPrice.toStringAsFixed(2)} × ${item.quantity}'
                                            : 'Price pending × ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: theme.colorScheme
                                                .outlineVariant
                                                .withAlpha(128),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              iconSize: 18,
                                              padding: const EdgeInsets.all(4),
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: item.quantity > 1
                                                  ? () => _updateItemQuantity(
                                                      index, item.quantity - 1)
                                                  : null,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              iconSize: 18,
                                              padding: const EdgeInsets.all(4),
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () =>
                                                  _updateItemQuantity(
                                                      index, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Bar: Total Amount & Review Order Button
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_currentDraft.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _navigateToReviewOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentDraft.isNotEmpty
                              ? const Color(0xFF0D9488)
                              : theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(160),
                          foregroundColor: _currentDraft.isNotEmpty
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant
                                  .withAlpha(160),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Review Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantSelectionModal extends ConsumerStatefulWidget {
  final Medicine medicine;
  final Function(MedicineVariant variant, int quantity) onAddToCart;

  const _VariantSelectionModal({
    required this.medicine,
    required this.onAddToCart,
  });

  @override
  ConsumerState<_VariantSelectionModal> createState() =>
      _VariantSelectionModalState();
}

class _VariantSelectionModalState
    extends ConsumerState<_VariantSelectionModal> {
  MedicineVariant? _selectedVariant;
  int _quantity = 1;
  final TextEditingController _qtyController =
      TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _quantity++;
      _qtyController.text = '$_quantity';
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _qtyController.text = '$_quantity';
      });
    }
  }

  void _submit() {
    if (_selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a variant.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final parsedQty = int.tryParse(_qtyController.text.trim());
    if (parsedQty == null || parsedQty < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive quantity.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onAddToCart(_selectedVariant!, parsedQty);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variantsAsync =
        ref.watch(activeMedicineVariantsProvider(widget.medicine.id));

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.medicine.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.medicine.brand} • ${widget.medicine.composition}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Variants List Section
          Text(
            'Select Active Variant',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          variantsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Failed to load variants: $err'),
            ),
            data: (variants) {
              final activeVariants =
                  variants.where((v) => v.active).toList();

              if (activeVariants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No active variants available for this medicine.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: activeVariants.map((variant) {
                  final isSelected = _selectedVariant?.id == variant.id;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : theme.colorScheme.outlineVariant.withAlpha(128),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    color: isSelected
                        ? const Color(0xFF0D9488).withAlpha(16)
                        : theme.colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedVariant = variant;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? const Color(0xFF0D9488)
                                  : theme.colorScheme.outlineVariant,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${variant.form} • ${variant.strength} • ${variant.packSize}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        'MRP ₹${variant.mrp.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Supplier ₹${variant.supplierPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F766E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Quantity Section
          Text(
            'Quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _decrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _qtyController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    final p = int.tryParse(val);
                    if (p != null) {
                      _quantity = p;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              if (_selectedVariant != null)
                Text(
                  'Item Total: ₹${(_selectedVariant!.supplierPrice * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F766E),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _selectedVariant != null ? _submit : null,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
