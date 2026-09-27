import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item.dart';

/// Immutable historical order record stored in the top-level 'orders' collection.
class OrderModel {
  final String id;
  final String orderNumber;
  final Map<String, dynamic> representative;
  final Map<String, dynamic> doctor;
  final Map<String, dynamic> chemist;
  final List<OrderItem> items;
  final int totalItems;
  final int totalQuantity;
  final double totalAmount;
  final String status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.representative,
    required this.doctor,
    required this.chemist,
    required this.items,
    required this.totalItems,
    required this.totalQuantity,
    required this.totalAmount,
    required this.status,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  // Representative snapshot getters
  String get representativeId => representative['id'] as String? ?? '';
  String get representativeName => representative['name'] as String? ?? '';
  String get representativeEmail => representative['email'] as String? ?? '';

  // Doctor snapshot getters
  String get doctorId => doctor['id'] as String? ?? '';
  String get doctorName => doctor['name'] as String? ?? '';
  String get doctorSpecialization => doctor['specialization'] as String? ?? '';
  String get doctorPhone => doctor['phone'] as String? ?? '';

  // Chemist snapshot getters
  String get chemistId => chemist['id'] as String? ?? '';
  String get chemistName => chemist['name'] as String? ?? '';
  String get chemistPhone => chemist['phone'] as String? ?? '';
  String get chemistAddress => chemist['address'] as String? ?? '';

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    double parseNumeric(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();

    return OrderModel(
      id: id,
      orderNumber: data['orderNumber'] as String? ?? '',
      representative: Map<String, dynamic>.from(data['representative'] as Map? ?? {}),
      doctor: Map<String, dynamic>.from(data['doctor'] as Map? ?? {}),
      chemist: Map<String, dynamic>.from(data['chemist'] as Map? ?? {}),
      items: items,
      totalItems: parseInt(data['totalItems']),
      totalQuantity: parseInt(data['totalQuantity']),
      totalAmount: parseNumeric(data['totalAmount']),
      status: data['status'] as String? ?? 'pending',
      notes: data['notes'] as String? ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool forCreate = false}) {
    return {
      'orderNumber': orderNumber,
      'representative': representative,
      'doctor': doctor,
      'chemist': chemist,
      'items': items.map((i) => i.toMap()).toList(),
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      if (forCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    Map<String, dynamic>? representative,
    Map<String, dynamic>? doctor,
    Map<String, dynamic>? chemist,
    List<OrderItem>? items,
    int? totalItems,
    int? totalQuantity,
    double? totalAmount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      representative: representative ?? this.representative,
      doctor: doctor ?? this.doctor,
      chemist: chemist ?? this.chemist,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
