import 'chemist.dart';
import 'doctor.dart';
import 'order_draft_item.dart';

/// In-memory order draft holding the selected Doctor, Chemist, and cart items
/// for the representative order creation workflow.
///
/// NOTE: This draft is purely in-memory and is NOT written to Firestore at this stage.
class OrderDraft {
  final Doctor doctor;
  final Chemist chemist;
  final List<OrderDraftItem> items;
  final String notes;

  const OrderDraft({
    required this.doctor,
    required this.chemist,
    this.items = const [],
    this.notes = '',
  });

  String get doctorId => doctor.id;
  String get doctorName => doctor.name;
  String get doctorSpecialization => doctor.specialization;
  String get doctorPhone => doctor.phone;

  String get chemistId => chemist.id;
  String get chemistName => chemist.name;
  String get chemistPhone => chemist.phone;
  String get chemistAddress => chemist.address;

  /// Total number of unique variant lines in the cart
  int get totalItems => items.length;

  /// Total units/quantity across all items
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Grand total price based on supplier prices: sum(supplierPrice * quantity)
  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.itemTotal);

  /// Whether the cart is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the cart has at least one item
  bool get isNotEmpty => items.isNotEmpty;

  OrderDraft copyWith({
    Doctor? doctor,
    Chemist? chemist,
    List<OrderDraftItem>? items,
    String? notes,
  }) {
    return OrderDraft(
      doctor: doctor ?? this.doctor,
      chemist: chemist ?? this.chemist,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}
