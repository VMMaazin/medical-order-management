class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;
  final bool active;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.active,
  });

  bool get isAdmin => role == 'admin';
  bool get isMedicalRep => role == 'medical_rep';

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      active: data['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'active': active,
    };
  }
}
