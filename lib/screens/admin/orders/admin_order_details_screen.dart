import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../models/order.dart';
import '../../../providers/order_provider.dart';
import '../../../services/order_pdf_service.dart';

class AdminOrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const AdminOrderDetailsScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  ConsumerState<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState
    extends ConsumerState<AdminOrderDetailsScreen> {
  bool _isUpdating = false;
  bool _isGeneratingPdf = false;

  Future<void> _generatePdf(OrderModel order) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfBytes = await OrderPdfService.generateOrderPdf(order);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: '${order.orderNumber.isNotEmpty ? order.orderNumber : "order"}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d-$m-$y $hh:$mm';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF0284C7);
      case 'processing':
        return const Color(0xFF7C3AED);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _showStatusUpdateBottomSheet(BuildContext context, OrderModel order) {
    const statuses = [
      {'key': 'pending', 'label': 'Pending', 'desc': 'Awaiting admin review'},
      {'key': 'confirmed', 'label': 'Confirmed', 'desc': 'Order verified and accepted'},
      {'key': 'processing', 'label': 'Processing', 'desc': 'Packing and fulfillment in progress'},
      {'key': 'delivered', 'label': 'Delivered', 'desc': 'Order successfully fulfilled'},
      {'key': 'cancelled', 'label': 'Cancelled', 'desc': 'Order cancelled or rejected'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Update Order Status',
                      style: Theme.of(bottomSheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
                Text(
                  'Current status: ${order.status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
                const SizedBox(height: 16),
                ...statuses.map((s) {
                  final key = s['key']!;
                  final label = s['label']!;
                  final desc = s['desc']!;
                  final isCurrent = order.status.toLowerCase() == key;
                  final statusColor = _getStatusColor(key);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? statusColor
                            : Colors.grey.withAlpha(50),
                        width: isCurrent ? 2 : 1,
                      ),
                      color: isCurrent
                          ? statusColor.withAlpha(15)
                          : Colors.transparent,
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: statusColor.withAlpha(30),
                        child: Icon(
                          isCurrent
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? statusColor : null,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isCurrent
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CURRENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop();
                        if (!isCurrent) {
                          _confirmAndChangeStatus(order, key, label);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndChangeStatus(
    OrderModel order,
    String newStatusKey,
    String newStatusLabel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Order Status?'),
        content: Text(
          'Are you sure you want to change order ${order.orderNumber} status from "${order.status.toUpperCase()}" to "$newStatusLabel"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(newStatusKey),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(
        orderId: order.id,
        status: newStatusKey,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatusLabel'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderStream = ref.watch(singleOrderStreamProvider(widget.orderId));
    final resolvedOrder = orderStream.asData?.value ?? widget.initialOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Order Details'),
        centerTitle: false,
        actions: [
          if (resolvedOrder != null)
            IconButton(
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Generate PDF',
              onPressed:
                  _isGeneratingPdf ? null : () => _generatePdf(resolvedOrder),
            ),
        ],
      ),
      body: orderStream.when(
        data: (order) {
          final displayOrder = order ?? widget.initialOrder;
          if (displayOrder == null) {
            return const Center(child: Text('Order not found.'));
          }

          final statusColor = _getStatusColor(displayOrder.status);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. ORDER INFORMATION Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(128),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayOrder.orderNumber,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F766E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusColor.withAlpha(100),
                                ),
                              ),
                              child: Text(
                                displayOrder.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${_formatDate(displayOrder.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items & Quantity',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${displayOrder.totalItems} items (${displayOrder.totalQuantity} units)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '₹${displayOrder.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Update Status Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isUpdating
                                ? null
                                : () => _showStatusUpdateBottomSheet(
                                      context,
                                      displayOrder,
                                    ),
                            icon: _isUpdating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.edit_note_rounded),
                            label: Text(
                              _isUpdating ? 'Updating...' : 'Update Status',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Generate PDF Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isGeneratingPdf
                                ? null
                                : () => _generatePdf(displayOrder),
                            icon: _isGeneratingPdf
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: Color(0xFF0F766E),
                                  ),
                            label: Text(
                              _isGeneratingPdf
                                  ? 'Generating PDF...'
                                  : 'Generate PDF',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F766E),
                              side: const BorderSide(color: Color(0xFF0F766E)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. REPRESENTATIVE SNAPSHOT
                  _buildSectionHeader('REPRESENTATIVE', Icons.badge_outlined),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(128),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF0D9488),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayOrder.representativeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayOrder.representativeEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. DOCTOR SNAPSHOT
                  _buildSectionHeader(
                    'DOCTOR',
                    Icons.medical_services_outlined,
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(128),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayOrder.doctorName.startsWith('Dr.')
                                ? displayOrder.doctorName
                                : 'Dr. ${displayOrder.doctorName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayOrder.doctorSpecialization,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                displayOrder.doctorPhone,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. CHEMIST SNAPSHOT
                  _buildSectionHeader(
                    'CHEMIST',
                    Icons.local_pharmacy_outlined,
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withAlpha(128),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayOrder.chemistName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                displayOrder.chemistPhone,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  displayOrder.chemistAddress,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ORDER NOTES / INSTRUCTIONS (if provided)
                  if (displayOrder.notes.trim().isNotEmpty) ...[
                    _buildSectionHeader(
                      'ORDER NOTES / INSTRUCTIONS',
                      Icons.note_alt_outlined,
                    ),
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF59E0B).withAlpha(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFF59E0B).withAlpha(120),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Note from Representative:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayOrder.notes.trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF78350F),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 5. MEDICINES SNAPSHOT LIST
                  _buildSectionHeader(
                    'MEDICINES (${displayOrder.items.length})',
                    Icons.medication_outlined,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayOrder.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = displayOrder.items[index];

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withAlpha(128),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          '${item.brand.isNotEmpty ? item.brand : (item.isCustom ? "Custom" : "")}${item.brand.isNotEmpty && item.composition.isNotEmpty ? " • " : ""}${item.composition}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${item.itemTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  if (item.isCustom)
                                    _buildTag(theme, 'Custom Medicine'),
                                  if (item.form.isNotEmpty &&
                                      item.form != 'Custom')
                                    _buildTag(theme, item.form),
                                  if (item.strength.isNotEmpty)
                                    _buildTag(theme, item.strength),
                                  if (item.packSize.isNotEmpty)
                                    _buildTag(theme, item.packSize),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'MRP: ₹${item.mrp.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'Supplier: ₹${item.supplierPrice.toStringAsFixed(2)} × ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => widget.initialOrder != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(widget.initialOrder!.orderNumber),
                    Text(widget.initialOrder!.doctorName),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading order details: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0D9488)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF0F766E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
