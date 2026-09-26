import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medical_rep.dart';
import '../services/medical_rep_service.dart';

final medicalRepServiceProvider = Provider<MedicalRepService>((ref) {
  return MedicalRepService();
});

class MedicalRepSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final medicalRepSearchQueryProvider =
    NotifierProvider<MedicalRepSearchQueryNotifier, String>(
  MedicalRepSearchQueryNotifier.new,
);

class MedicalRepShowInactiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setShowInactive(bool value) => state = value;
}

final medicalRepShowInactiveProvider =
    NotifierProvider<MedicalRepShowInactiveNotifier, bool>(
  MedicalRepShowInactiveNotifier.new,
);

final medicalRepsStreamProvider =
    StreamProvider.autoDispose<List<MedicalRep>>((ref) {
  final showInactive = ref.watch(medicalRepShowInactiveProvider);
  final service = ref.watch(medicalRepServiceProvider);
  return service.watchMedicalReps(includeInactive: showInactive);
});

final filteredMedicalRepsProvider =
    Provider.autoDispose<AsyncValue<List<MedicalRep>>>((ref) {
  final repsAsync = ref.watch(medicalRepsStreamProvider);
  final query = ref.watch(medicalRepSearchQueryProvider).toLowerCase().trim();

  return repsAsync.whenData((reps) {
    if (query.isEmpty) return reps;
    return reps.where((rep) {
      final matchesName = rep.name.toLowerCase().contains(query);
      final matchesEmail = rep.email.toLowerCase().contains(query);
      final matchesPhone = rep.phone.toLowerCase().contains(query);
      return matchesName || matchesEmail || matchesPhone;
    }).toList();
  });
});

final singleMedicalRepProvider =
    StreamProvider.autoDispose.family<MedicalRep?, String>((ref, id) {
  return ref.watch(medicalRepServiceProvider).watchMedicalRep(id);
});
