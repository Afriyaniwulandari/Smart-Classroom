class User {
  final String id;
  final String email;
  final String name;
  final String role; // student, teacher, admin
  final String? phone;
  final String? profilePicture;
  final String? className;
  final List<String>? interests;
  final DateTime? createdAt;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.profilePicture,
    this.className,
    this.interests,
    this.createdAt,
    this.isEmailVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      profilePicture: json['profilePicture'],
      className: json['className'],
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'profilePicture': profilePicture,
      'className': className,
      'interests': interests,
      'createdAt': createdAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? profilePicture,
    String? className,
    List<String>? interests,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      className: className ?? this.className,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}