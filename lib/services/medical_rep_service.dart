import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/medical_rep.dart';

class MedicalRepService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  MedicalRepService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

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

  /// Provision a real Medical Representative account securely via Cloud Functions.
  /// Server-side Admin SDK creates the Firebase Auth user and users/{UID} profile,
  /// ensuring the currently logged-in administrator's session is never disrupted.
  Future<String> provisionMedicalRep({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final callable = _functions.httpsCallable('createMedicalRep');
    final result = await callable.call<Map<String, dynamic>>({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
    });

    final data = Map<String, dynamic>.from(result.data);
    final uid = data['uid'] as String?;
    if (uid == null || uid.isEmpty) {
      throw Exception('Server did not return a valid user ID.');
    }
    return uid;
  }

  /// Create a profile directly in Firestore (Stage 1 / fallback)
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

  /// Safely remove a legacy Stage 1 test profile that has no associated Firebase Auth user
  Future<void> deleteLegacyProfile(String id) async {
    await _usersCollection.doc(id).delete();
  }
}
