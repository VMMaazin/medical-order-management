import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';

final doctorServiceProvider = Provider<DoctorService>((ref) {
  return DoctorService();
});

class DoctorSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final doctorSearchQueryProvider =
    NotifierProvider<DoctorSearchQueryNotifier, String>(
  DoctorSearchQueryNotifier.new,
);

class DoctorShowInactiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setShowInactive(bool value) => state = value;
}

final doctorShowInactiveProvider =
    NotifierProvider<DoctorShowInactiveNotifier, bool>(
  DoctorShowInactiveNotifier.new,
);

final doctorsStreamProvider = StreamProvider.autoDispose<List<Doctor>>((ref) {
  final showInactive = ref.watch(doctorShowInactiveProvider);
  final service = ref.watch(doctorServiceProvider);
  return service.watchDoctors(includeInactive: showInactive);
});

final filteredDoctorsProvider =
    Provider.autoDispose<AsyncValue<List<Doctor>>>((ref) {
  final doctorsAsync = ref.watch(doctorsStreamProvider);
  final query = ref.watch(doctorSearchQueryProvider).toLowerCase().trim();

  return doctorsAsync.whenData((doctors) {
    if (query.isEmpty) return doctors;
    return doctors.where((doc) {
      final matchesName = doc.name.toLowerCase().contains(query);
      final matchesSpec = doc.specialization.toLowerCase().contains(query);
      final matchesPhone = doc.phone.toLowerCase().contains(query);
      return matchesName || matchesSpec || matchesPhone;
    }).toList();
  });
});

final singleDoctorProvider =
    StreamProvider.autoDispose.family<Doctor?, String>((ref, id) {
  return ref.watch(doctorServiceProvider).watchDoctor(id);
});

final activeDoctorsStreamProvider = StreamProvider.autoDispose<List<Doctor>>((ref) {
  final service = ref.watch(doctorServiceProvider);
  return service.watchDoctors(includeInactive: false);
});
