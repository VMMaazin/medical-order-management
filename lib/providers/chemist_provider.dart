import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chemist.dart';
import '../services/chemist_service.dart';

final chemistServiceProvider = Provider<ChemistService>((ref) {
  return ChemistService();
});

class ChemistSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final chemistSearchQueryProvider =
    NotifierProvider<ChemistSearchQueryNotifier, String>(
  ChemistSearchQueryNotifier.new,
);

class ChemistShowInactiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setShowInactive(bool value) => state = value;
}

final chemistShowInactiveProvider =
    NotifierProvider<ChemistShowInactiveNotifier, bool>(
  ChemistShowInactiveNotifier.new,
);

final chemistsStreamProvider = StreamProvider.autoDispose<List<Chemist>>((ref) {
  final showInactive = ref.watch(chemistShowInactiveProvider);
  final service = ref.watch(chemistServiceProvider);
  return service.watchChemists(includeInactive: showInactive);
});

final filteredChemistsProvider =
    Provider.autoDispose<AsyncValue<List<Chemist>>>((ref) {
  final chemistsAsync = ref.watch(chemistsStreamProvider);
  final query = ref.watch(chemistSearchQueryProvider).toLowerCase().trim();

  return chemistsAsync.whenData((chemists) {
    if (query.isEmpty) return chemists;
    return chemists.where((ch) {
      final matchesName = ch.name.toLowerCase().contains(query);
      final matchesPhone = ch.phone.toLowerCase().contains(query);
      final matchesAddress = ch.address.toLowerCase().contains(query);
      return matchesName || matchesPhone || matchesAddress;
    }).toList();
  });
});

final singleChemistProvider =
    StreamProvider.autoDispose.family<Chemist?, String>((ref, id) {
  return ref.watch(chemistServiceProvider).watchChemist(id);
});

final activeChemistsStreamProvider = StreamProvider.autoDispose<List<Chemist>>((ref) {
  final service = ref.watch(chemistServiceProvider);
  return service.watchChemists(includeInactive: false);
});
