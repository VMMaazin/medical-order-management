/// In-memory snapshot of a selected medicine variant and quantity for an order draft.
///
/// Stores a snapshot of the medicine and variant data at the time of addition.
/// Does NOT rely on Firestore documents once added to the cart.
class OrderDraftItem {
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
  final bool isCustom;

  const OrderDraftItem({
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
    this.isCustom = false,
  });

  /// Calculates total price for this cart item snapshot: supplierPrice * quantity
  double get itemTotal => supplierPrice * quantity;

  OrderDraftItem copyWith({
    String? medicineId,
    String? medicineName,
    String? brand,
    String? composition,
    String? variantId,
    String? form,
    String? strength,
    String? packSize,
    double? mrp,
    double? supplierPrice,
    int? quantity,
    bool? isCustom,
  }) {
    return OrderDraftItem(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      brand: brand ?? this.brand,
      composition: composition ?? this.composition,
      variantId: variantId ?? this.variantId,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      packSize: packSize ?? this.packSize,
      mrp: mrp ?? this.mrp,
      supplierPrice: supplierPrice ?? this.supplierPrice,
      quantity: quantity ?? this.quantity,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
