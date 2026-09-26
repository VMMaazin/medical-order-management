import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/medical_rep.dart';

class MedicalRepService {
  final FirebaseFirestore _firestore;

  MedicalRepService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

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

  /// Provision a real Medical Representative account using a SECOND FirebaseAuth instance.
  /// This runs on the 100% free Spark plan without requiring Cloud Functions or Blaze.
  ///
  /// CRITICAL ARCHITECTURAL GUARANTEE:
  /// The currently logged-in administrator's primary [FirebaseAuth.instance] session
  /// is never touched, signed out, or replaced.
  Future<String> provisionMedicalRep({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    const secondaryAppName = 'repAccountCreation';
    FirebaseApp secondaryApp;

    // 1. Initialize or retrieve the secondary FirebaseApp
    try {
      secondaryApp = Firebase.app(secondaryAppName);
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    String? newUid;

    try {
      // 2. Create the representative account on the secondary Auth instance
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Failed to obtain user details after account creation.',
        );
      }

      newUid = user.uid;

      // Update the representative's display name
      try {
        await user.updateDisplayName(name.trim());
      } catch (_) {}

      // 3. Create users/{UID} profile document in Firestore using primary Admin session
      await _usersCollection.doc(newUid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': 'medical_rep',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newUid;
    } catch (e) {
      // Partial failure handling: if Auth user was created but Firestore failed,
      // report error clearly without disturbing the Admin's session.
      rethrow;
    } finally {
      // 4. Always sign out the secondary Auth instance
      try {
        await secondaryAuth.signOut();
      } catch (_) {}

      // 5. Cleanly delete the secondary FirebaseApp instance
      try {
        await secondaryApp.delete();
      } catch (_) {}
    }
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
