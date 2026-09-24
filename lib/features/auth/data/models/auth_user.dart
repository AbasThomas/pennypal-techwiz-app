class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.isEmailVerified,
    this.role = 'student',
    this.phoneNumber,
  });
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool? isEmailVerified;
  final String role;
  final String? phoneNumber;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool?,
    role: (json['role'] ?? 'student').toString(),
    phoneNumber: json['phoneNumber'] as String?,
  );
}
