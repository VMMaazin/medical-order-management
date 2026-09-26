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

                    // Medicines Header
                    Text(
                      'Medicines Catalog',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                            child: const Column(
                              children: [
                                Icon(Icons.medication_outlined,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No active medicines available.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                            child: const Column(
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No medicines found.',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                                            Text(
                                              item.medicineName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.form} • ${item.strength} • ${item.packSize}',
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
                                        '₹${item.supplierPrice.toStringAsFixed(2)} × ${item.quantity}',
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
