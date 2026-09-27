class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.isEmailVerified,
    this.role = 'student',
    this.phoneNumber,
    this.photoUrl,
    this.institution,
    this.bio,
    this.isDeactivated,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool? isEmailVerified;
  final String role;
  final String? phoneNumber;
  final String? photoUrl;
  final String? institution;
  final String? bio;
  final bool? isDeactivated;

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().where((s) => s.trim().isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ').trim() : email.split('@').first;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool?,
    role: (json['role'] ?? 'student').toString(),
    phoneNumber: json['phoneNumber'] as String?,
    photoUrl: json['photoUrl'] as String?,
    institution: json['institution'] as String?,
    bio: json['bio'] as String?,
    isDeactivated: json['isDeactivated'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'fullName': fullName,
    'isEmailVerified': isEmailVerified,
    'role': role,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'institution': institution,
    'bio': bio,
    'isDeactivated': isDeactivated ?? false,
  };

  AuthUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isEmailVerified,
    String? role,
    String? phoneNumber,
    String? photoUrl,
    String? institution,
    String? bio,
    bool? isDeactivated,
  }) => AuthUser(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    role: role ?? this.role,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    photoUrl: photoUrl ?? this.photoUrl,
    institution: institution ?? this.institution,
    bio: bio ?? this.bio,
    isDeactivated: isDeactivated ?? this.isDeactivated ?? false,
  );
}
