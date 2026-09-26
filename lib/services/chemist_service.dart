import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chemist.dart';

class ChemistService {
  final FirebaseFirestore _firestore;

  ChemistService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chemistsCollection =>
      _firestore.collection('chemists');

  /// Stream all chemists, optionally including inactive ones
  Stream<List<Chemist>> watchChemists({bool includeInactive = false}) {
    Query<Map<String, dynamic>> query = _chemistsCollection;

    if (!includeInactive) {
      query = query.where('active', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Chemist.fromFirestore(doc.data(), doc.id);
      }).toList();

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Get single chemist by document ID
  Future<Chemist?> getChemist(String id) async {
    final doc = await _chemistsCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return Chemist.fromFirestore(doc.data()!, doc.id);
  }

  /// Watch single chemist document
  Stream<Chemist?> watchChemist(String id) {
    return _chemistsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Chemist.fromFirestore(doc.data()!, doc.id);
    });
  }

  /// Add a new chemist (automatically generated ID)
  Future<String> addChemist({
    required String name,
    required String phone,
    required String address,
  }) async {
    final docRef = await _chemistsCollection.add({
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update an existing chemist
  Future<void> updateChemist({
    required String id,
    required String name,
    required String phone,
    required String address,
    bool? active,
  }) async {
    final Map<String, dynamic> data = {
      'name': name.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (active != null) {
      data['active'] = active;
    }

    await _chemistsCollection.doc(id).update(data);
  }

  /// Soft deactivate / reactivate chemist
  Future<void> setChemistActiveStatus(String id, bool active) async {
    await _chemistsCollection.doc(id).update({
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
