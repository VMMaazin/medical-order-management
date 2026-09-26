import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    return Doctor(
      id: id,
      name: data['name'] as String? ?? '',
      specialization: data['specialization'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'active': active,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialization,
    String? phone,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
