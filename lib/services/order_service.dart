import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/order.dart';
import '../models/order_draft.dart';
import '../models/order_item.dart';

class OrderService {
  final FirebaseFirestore? _firestoreInstance;
  final FirebaseAuth? _authInstance;

  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestoreInstance = firestore,
        _authInstance = auth;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  /// Generate a human-readable, unique order number: ORD-YYYYMMDD-XXXX
  Future<String> generateOrderNumber() async {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final dateStr = '$year$month$day';

    try {
      final counterRef =
          _firestore.collection('counters').doc('order_counter');

      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(counterRef);
        int count = 1;

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data['date'] == dateStr) {
            count = ((data['count'] as num?)?.toInt() ?? 0) + 1;
          }
        }

        transaction.set(counterRef, {
          'date': dateStr,
          'count': count,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final suffix = count.toString().padLeft(4, '0');
        return 'ORD-$dateStr-$suffix';
      });
    } catch (_) {
      // Safe fallback if counter doc is inaccessible or during offline/mock test
      final randomSuffix = (Random().nextInt(9000) + 1000).toString();
      return 'ORD-$dateStr-$randomSuffix';
    }
  }

  /// Create and submit a complete historical order to Firestore
  Future<OrderModel> createOrder({
    required OrderDraft draft,
    AppUser? representativeProfile,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    if (draft.isEmpty) {
      throw Exception('Cannot submit an order with zero items.');
    }

    // Get representative snapshot data securely using authenticated UID
    String repName = representativeProfile?.name ?? '';
    String repEmail = representativeProfile?.email ?? currentUser.email ?? '';

    if (repName.trim().isEmpty) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          repName = userDoc.data()!['name'] as String? ?? 'Representative';
          repEmail = userDoc.data()!['email'] as String? ?? repEmail;
        }
      } catch (_) {
        repName = 'Representative';
      }
    }

    final repSnapshot = {
      'id': currentUser.uid,
      'name': repName.trim().isNotEmpty ? repName.trim() : 'Representative',
      'email': repEmail.trim(),
    };

    final docSnapshot = {
      'id': draft.doctorId,
      'name': draft.doctorName,
      'specialization': draft.doctorSpecialization,
      'phone': draft.doctorPhone,
    };

    final chemistSnapshot = {
      'id': draft.chemistId,
      'name': draft.chemistName,
      'phone': draft.chemistPhone,
      'address': draft.chemistAddress,
    };

    final orderItems =
        draft.items.map((i) => OrderItem.fromDraftItem(i)).toList();
    final orderNumber = await generateOrderNumber();

    final docData = <String, dynamic>{
      'orderNumber': orderNumber,
      'representative': repSnapshot,
      'doctor': docSnapshot,
      'chemist': chemistSnapshot,
      'items': orderItems.map((i) => i.toMap()).toList(),
      'totalItems': draft.totalItems,
      'totalQuantity': draft.totalQuantity,
      'totalAmount': draft.totalAmount,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _ordersCollection.add(docData);

    return OrderModel(
      id: docRef.id,
      orderNumber: orderNumber,
      representative: repSnapshot,
      doctor: docSnapshot,
      chemist: chemistSnapshot,
      items: orderItems,
      totalItems: draft.totalItems,
      totalQuantity: draft.totalQuantity,
      totalAmount: draft.totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Stream all orders belonging to a specific representative, newest first
  Stream<List<OrderModel>> watchMyOrders(String representativeId) {
    return _ordersCollection
        .where('representative.id', isEqualTo: representativeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return list;
    });
  }

  /// Retrieve single order document by ID
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return OrderModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Stream single order document by ID
  Stream<OrderModel?> watchOrder(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Stream all orders for admin, sorted by newest first
  Stream<List<OrderModel>> watchAllOrders() {
    return _ordersCollection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return list;
    });
  }

  /// Update status of an existing order (Admin only)
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    const validStatuses = [
      'pending',
      'confirmed',
      'processing',
      'delivered',
      'cancelled',
    ];
    final normalized = status.toLowerCase().trim();
    if (!validStatuses.contains(normalized)) {
      throw ArgumentError('Invalid order status: $status');
    }

    await _ordersCollection.doc(orderId).update({
      'status': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
