/// Teacher data model.
///
/// PRODUCTION NOTE: The `password` field exists only for local demo/testing.
/// A real implementation must use:
///   - Secure server-side authentication
///   - Password hashing (bcrypt / Argon2)
///   - JWT tokens or session cookies
///   - Never store plaintext passwords anywhere
class Teacher {
  final String id;
  final String name;
  final String email;

  /// Demo credential only — NOT secure for production use.
  final String password;

  final bool active;

  const Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.active = true,
  });

  /// Returns initials from the teacher's name
  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      active: (json['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'active': active,
    };
  }

  @override
  bool operator ==(Object other) => other is Teacher && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Teacher($id, $name)';
}
