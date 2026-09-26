import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRep {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicalRep({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'medical_rep',
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalRep.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    return MedicalRep(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'medical_rep',
      active: data['active'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'active': active,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  MedicalRep copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRep(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
