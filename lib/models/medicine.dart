import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String brand;
  final String composition;
  final String category;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medicine({
    required this.id,
    required this.name,
    required this.brand,
    required this.composition,
    required this.category,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Medicine.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    return Medicine(
      id: id,
      name: data['name'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      composition: data['composition'] as String? ?? '',
      category: data['category'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'composition': composition,
      'category': category,
      'active': active,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? brand,
    String? composition,
    String? category,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      composition: composition ?? this.composition,
      category: category ?? this.category,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
