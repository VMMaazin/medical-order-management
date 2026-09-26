import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor.dart';

class DoctorService {
  final FirebaseFirestore _firestore;

  DoctorService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _doctorsCollection =>
      _firestore.collection('doctors');

  /// Stream all doctors, optionally including inactive ones
  Stream<List<Doctor>> watchDoctors({bool includeInactive = false}) {
    Query<Map<String, dynamic>> query = _doctorsCollection;

    if (!includeInactive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Doctor.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Get single doctor by document ID
  Future<Doctor?> getDoctor(String id) async {
    final doc = await _doctorsCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Doctor.fromFirestore(doc.data()!, doc.id);
  }

  /// Watch single doctor document
  Stream<Doctor?> watchDoctor(String id) {
    return _doctorsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Doctor.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Add a new doctor (automatically generated ID)
  Future<String> addDoctor({
    required String name,
    required String specialization,
    required String phone,
  }) async {
    final docRef = await _doctorsCollection.add({
      'name': name.trim(),
      'specialization': specialization.trim(),
      'phone': phone.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update an existing doctor
  Future<void> updateDoctor({
    required String id,
    required String name,
    required String specialization,
    required String phone,
    bool? active,
  }) async {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      'specialization': specialization.trim(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (active != null) {
      data['active'] = active;
    }

    await _doctorsCollection.doc(id).update(data);
  }

  /// Soft deactivate / reactivate doctor
  Future<void> setDoctorActiveStatus(String id, bool active) async {
    await _doctorsCollection.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
