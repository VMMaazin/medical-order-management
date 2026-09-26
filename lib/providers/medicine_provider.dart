import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medicine.dart';
import '../models/medicine_variant.dart';
import '../services/medicine_service.dart';

final medicineServiceProvider = Provider<MedicineService>((ref) {
  return MedicineService();
});

class MedicineSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final medicineSearchQueryProvider =
    NotifierProvider<MedicineSearchQueryNotifier, String>(
  MedicineSearchQueryNotifier.new,
);

class MedicineShowInactiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setShowInactive(bool value) => state = value;
}

final medicineShowInactiveProvider =
    NotifierProvider<MedicineShowInactiveNotifier, bool>(
  MedicineShowInactiveNotifier.new,
);

final medicinesStreamProvider =
    StreamProvider.autoDispose<List<Medicine>>((ref) {
  final showInactive = ref.watch(medicineShowInactiveProvider);
  final service = ref.watch(medicineServiceProvider);
  return service.watchMedicines(includeInactive: showInactive);
});

final filteredMedicinesProvider =
    Provider.autoDispose<AsyncValue<List<Medicine>>>((ref) {
  final medicinesAsync = ref.watch(medicinesStreamProvider);
  final query = ref.watch(medicineSearchQueryProvider).toLowerCase().trim();

  return medicinesAsync.whenData((medicines) {
    if (query.isEmpty) return medicines;
    return medicines.where((med) {
      final matchesName = med.name.toLowerCase().contains(query);
      final matchesBrand = med.brand.toLowerCase().contains(query);
      final matchesComposition = med.composition.toLowerCase().contains(query);
      final matchesCategory = med.category.toLowerCase().contains(query);
      return matchesName || matchesBrand || matchesComposition || matchesCategory;
    }).toList();
  });
});

final singleMedicineProvider =
    StreamProvider.autoDispose.family<Medicine?, String>((ref, id) {
  return ref.watch(medicineServiceProvider).watchMedicine(id);
});

final medicineVariantsProvider = StreamProvider.autoDispose
    .family<List<MedicineVariant>, String>((ref, medicineId) {
  final showInactive = ref.watch(medicineShowInactiveProvider);
  return ref
      .watch(medicineServiceProvider)
      .watchVariants(medicineId, includeInactive: showInactive);
});

final medicineActiveVariantCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, medicineId) {
  return ref.watch(medicineServiceProvider).watchActiveVariantCount(medicineId);
});

final activeMedicinesStreamProvider =
    StreamProvider.autoDispose<List<Medicine>>((ref) {
  final service = ref.watch(medicineServiceProvider);
  return service.watchMedicines(includeInactive: false);
});

final activeMedicineVariantsProvider = StreamProvider.autoDispose
    .family<List<MedicineVariant>, String>((ref, medicineId) {
  final service = ref.watch(medicineServiceProvider);
  return service.watchVariants(medicineId, includeInactive: false);
});
