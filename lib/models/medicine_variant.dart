import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineVariant {
  final String id;
  final String medicineId;
  final String form;
  final String strength;
  final String packSize;
  final double mrp;
  final double supplierPrice;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MedicineVariant({
    required this.id,
    required this.medicineId,
    required this.form,
    required this.strength,
    required this.packSize,
    required this.mrp,
    required this.supplierPrice,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicineVariant.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    double parseNumeric(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return MedicineVariant(
      id: id,
      medicineId: data['medicineId'] as String? ?? '',
      form: data['form'] as String? ?? '',
      strength: data['strength'] as String? ?? '',
      packSize: data['packSize'] as String? ?? '',
      mrp: parseNumeric(data['mrp']),
      supplierPrice: parseNumeric(data['supplierPrice']),
      active: data['active'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineId': medicineId,
      'form': form,
      'strength': strength,
      'packSize': packSize,
      'mrp': mrp,
      'supplierPrice': supplierPrice,
      'active': active,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  MedicineVariant copyWith({
    String? id,
    String? medicineId,
    String? form,
    String? strength,
    String? packSize,
    double? mrp,
    double? supplierPrice,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineVariant(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      packSize: packSize ?? this.packSize,
      mrp: mrp ?? this.mrp,
      supplierPrice: supplierPrice ?? this.supplierPrice,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
