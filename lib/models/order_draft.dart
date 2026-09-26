import 'chemist.dart';
import 'doctor.dart';

/// In-memory order draft holding the selected Doctor and Chemist
/// for the representative order creation workflow.
///
/// NOTE: This draft is purely in-memory and is NOT written to Firestore at this stage.
class OrderDraft {
  final Doctor doctor;
  final Chemist chemist;

  const OrderDraft({
    required this.doctor,
    required this.chemist,
  });

  String get doctorId => doctor.id;
  String get doctorName => doctor.name;
  String get doctorSpecialization => doctor.specialization;
  String get doctorPhone => doctor.phone;

  String get chemistId => chemist.id;
  String get chemistName => chemist.name;
  String get chemistPhone => chemist.phone;
  String get chemistAddress => chemist.address;

  OrderDraft copyWith({
    Doctor? doctor,
    Chemist? chemist,
  }) {
    return OrderDraft(
      doctor: doctor ?? this.doctor,
      chemist: chemist ?? this.chemist,
    );
  }
}
