import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_rep.dart';

class MedicalRepService {
  final FirebaseFirestore _firestore;

  MedicalRepService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Stream all medical representatives, optionally including inactive ones
  Stream<List<MedicalRep>> watchMedicalReps({bool includeInactive = false}) {
    Query<Map<String, dynamic>> query =
        _usersCollection.where('role', isEqualTo: 'medical_rep');

    if (!includeInactive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return MedicalRep.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Get single medical representative by document ID
  Future<MedicalRep?> getMedicalRep(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return MedicalRep.fromFirestore(doc.data()!, doc.id);
  }

  /// Watch single medical representative document
  Stream<MedicalRep?> watchMedicalRep(String id) {
    return _usersCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return MedicalRep.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Create a new medical representative profile in Firestore
  /// Note: Stage 1 creates the profile document in the users collection.
  /// Authentication credential creation will be handled in Stage 2.
  Future<String> createMedicalRepProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final docRef = await _usersCollection.add({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'role': 'medical_rep',
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update an existing medical representative profile
  Future<void> updateMedicalRepProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    bool? active,
  }) async {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (active != null) {
      data['active'] = active;
    }

    await _usersCollection.doc(id).update(data);
  }

  /// Soft deactivate / reactivate medical representative
  Future<void> setMedicalRepActiveStatus(String id, bool active) async {
    await _usersCollection.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
