import 'order_draft_item.dart';

/// Immutable snapshot of an item within a submitted or pending order.
class OrderItem {
  final String medicineId;
  final String medicineName;
  final String brand;
  final String composition;
  final String variantId;
  final String form;
  final String strength;
  final String packSize;
  final double mrp;
  final double supplierPrice;
  final int quantity;
  final double itemTotal;

  const OrderItem({
    required this.medicineId,
    required this.medicineName,
    required this.brand,
    required this.composition,
    required this.variantId,
    required this.form,
    required this.strength,
    required this.packSize,
    required this.mrp,
    required this.supplierPrice,
    required this.quantity,
    required this.itemTotal,
  });

  factory OrderItem.fromDraftItem(OrderDraftItem draftItem) {
    return OrderItem(
      medicineId: draftItem.medicineId,
      medicineName: draftItem.medicineName,
      brand: draftItem.brand,
      composition: draftItem.composition,
      variantId: draftItem.variantId,
      form: draftItem.form,
      strength: draftItem.strength,
      packSize: draftItem.packSize,
      mrp: draftItem.mrp,
      supplierPrice: draftItem.supplierPrice,
      quantity: draftItem.quantity,
      itemTotal: draftItem.itemTotal,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    double parseNumeric(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 1;
      return 1;
    }

    final supplierPrice = parseNumeric(data['supplierPrice']);
    final quantity = parseInt(data['quantity']);
    final itemTotal = data['itemTotal'] != null
        ? parseNumeric(data['itemTotal'])
        : supplierPrice * quantity;

    return OrderItem(
      medicineId: data['medicineId'] as String? ?? '',
      medicineName: data['medicineName'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      composition: data['composition'] as String? ?? '',
      variantId: data['variantId'] as String? ?? '',
      form: data['form'] as String? ?? '',
      strength: data['strength'] as String? ?? '',
      packSize: data['packSize'] as String? ?? '',
      mrp: parseNumeric(data['mrp']),
      supplierPrice: supplierPrice,
      quantity: quantity,
      itemTotal: itemTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'brand': brand,
      'composition': composition,
      'variantId': variantId,
      'form': form,
      'strength': strength,
      'packSize': packSize,
      'mrp': mrp,
      'supplierPrice': supplierPrice,
      'quantity': quantity,
      'itemTotal': itemTotal,
    };
  }
}
