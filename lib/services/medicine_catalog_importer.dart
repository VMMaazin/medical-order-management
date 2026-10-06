import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/medicine_catalog_data.dart';

class ImportCatalogResult {
  final int totalInCatalog;
  final int medicinesAdded;
  final int variantsAdded;
  final int skippedAlreadyExist;

  const ImportCatalogResult({
    required this.totalInCatalog,
    required this.medicinesAdded,
    required this.variantsAdded,
    required this.skippedAlreadyExist,
  });
}

class MedicineCatalogImporter {
  final FirebaseFirestore _firestore;

  MedicineCatalogImporter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Imports all 165 medicines and variants into Firestore.
  /// Skips medicines that are already present (by name).
  Future<ImportCatalogResult> importCatalog({
    void Function(double progress, String currentItem)? onProgress,
  }) async {
    final medicinesCollection = _firestore.collection('medicines');
    final variantsCollection = _firestore.collection('medicineVariants');

    // 1. Fetch existing medicines to avoid duplicate creation
    final existingSnapshot = await medicinesCollection.get();
    final existingNames = <String, String>{}; // lowerName -> docId
    for (final doc in existingSnapshot.docs) {
      final name = (doc.data()['name'] as String? ?? '').toLowerCase().trim();
      if (name.isNotEmpty) {
        existingNames[name] = doc.id;
      }
    }

    int medicinesAdded = 0;
    int variantsAdded = 0;
    int skippedCount = 0;

    // Use batches of max 200 operations (each item has 2 writes = 400 operations)
    WriteBatch currentBatch = _firestore.batch();
    int batchOperations = 0;

    final total = kOfficialMedicineCatalog.length;

    for (int i = 0; i < total; i++) {
      final item = kOfficialMedicineCatalog[i];
      final normalizedName = item.name.toLowerCase().trim();

      onProgress?.call((i + 1) / total, item.name);

      if (existingNames.containsKey(normalizedName)) {
        skippedCount++;
        continue;
      }

      // Create new medicine document
      final medDocRef = medicinesCollection.doc();
      currentBatch.set(medDocRef, {
        'name': item.name.trim(),
        'brand': item.brand.trim(),
        'composition': item.composition.trim(),
        'category': item.category.trim(),
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      existingNames[normalizedName] = medDocRef.id;
      medicinesAdded++;
      batchOperations++;

      // Create matching variant document
      final variantDocRef = variantsCollection.doc();
      currentBatch.set(variantDocRef, {
        'medicineId': medDocRef.id,
        'form': item.form.trim(),
        'strength': item.strength.trim(),
        'packSize': item.packSize.trim(),
        'mrp': item.mrp,
        'supplierPrice': item.ptr,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      variantsAdded++;
      batchOperations++;

      // Commit batch if approaching Firestore limits (500 ops)
      if (batchOperations >= 400) {
        await currentBatch.commit();
        currentBatch = _firestore.batch();
        batchOperations = 0;
      }
    }

    // Commit any remaining operations
    if (batchOperations > 0) {
      await currentBatch.commit();
    }

    return ImportCatalogResult(
      totalInCatalog: total,
      medicinesAdded: medicinesAdded,
      variantsAdded: variantsAdded,
      skippedAlreadyExist: skippedCount,
    );
  }
}
