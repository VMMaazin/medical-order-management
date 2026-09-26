import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicine.dart';
import '../models/medicine_variant.dart';

class MedicineService {
  final FirebaseFirestore _firestore;

  MedicineService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _medicinesCollection =>
      _firestore.collection('medicines');

  CollectionReference<Map<String, dynamic>> get _variantsCollection =>
      _firestore.collection('medicineVariants');

  // ==================== MEDICINES ====================

  /// Stream all medicines, optionally filtering by active status
  Stream<List<Medicine>> watchMedicines({bool includeInactive = false}) {
    Query<Map<String, dynamic>> query = _medicinesCollection;

    if (!includeInactive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Medicine.fromFirestore(doc.data(), doc.id);
      }).toList();

      // Sort alphabetically by name on client side to avoid composite index requirements
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Get single medicine by id
  Future<Medicine?> getMedicine(String id) async {
    final doc = await _medicinesCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Medicine.fromFirestore(doc.data()!, doc.id);
  }

  /// Watch single medicine by id
  Stream<Medicine?> watchMedicine(String id) {
    return _medicinesCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Medicine.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Add a new parent medicine
  Future<String> addMedicine({
    required String name,
    required String brand,
    required String composition,
    required String category,
  }) async {
    final docRef = await _medicinesCollection.add({
      'name': name.trim(),
      'brand': brand.trim(),
      'composition': composition.trim(),
      'category': category.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update an existing medicine
  Future<void> updateMedicine({
    required String id,
    required String name,
    required String brand,
    required String composition,
    required String category,
    bool? active,
  }) async {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      'brand': brand.trim(),
      'composition': composition.trim(),
      'category': category.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (active != null) {
      data['active'] = active;
    }

    await _medicinesCollection.doc(id).update(data);
  }

  /// Deactivate / activate medicine
  Future<void> setMedicineActiveStatus(String id, bool active) async {
    await _medicinesCollection.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== MEDICINE VARIANTS ====================

  /// Stream variants for a specific medicine
  Stream<List<MedicineVariant>> watchVariants(
    String medicineId, {
    bool includeInactive = false,
  }) {
    Query<Map<String, dynamic>> query =
        _variantsCollection.where('medicineId', isEqualTo: medicineId);

    if (!includeInactive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return MedicineVariant.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) {
        final formComp = a.form.toLowerCase().compareTo(b.form.toLowerCase());
        if (formComp != 0) return formComp;
        return a.strength.toLowerCase().compareTo(b.strength.toLowerCase());
      });
      return list;
    });
  }

  /// Stream count of active variants for a medicine
  Stream<int> watchActiveVariantCount(String medicineId) {
    return _variantsCollection
        .where('medicineId', isEqualTo: medicineId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Add a new variant for a medicine
  Future<String> addVariant({
    required String medicineId,
    required String form,
    required String strength,
    required String packSize,
    required double mrp,
    required double supplierPrice,
  }) async {
    final docRef = await _variantsCollection.add({
      'medicineId': medicineId,
      'form': form.trim(),
      'strength': strength.trim(),
      'packSize': packSize.trim(),
      'mrp': mrp,
      'supplierPrice': supplierPrice,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update an existing variant
  Future<void> updateVariant({
    required String id,
    required String form,
    required String strength,
    required String packSize,
    required double mrp,
    required double supplierPrice,
    bool? active,
  }) async {
    final Map<String, dynamic> data = {
      'form': form.trim(),
      'strength': strength.trim(),
      'packSize': packSize.trim(),
      'mrp': mrp,
      'supplierPrice': supplierPrice,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (active != null) {
      data['active'] = active;
    }

    await _variantsCollection.doc(id).update(data);
  }

  /// Deactivate / activate variant
  Future<void> setVariantActiveStatus(String id, bool active) async {
    await _variantsCollection.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
