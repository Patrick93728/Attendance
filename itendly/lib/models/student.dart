class Student {
  final String id;
  final String surname;
  final String firstname;
  final String middlename;
  final bool active;

  const Student({
    required this.id,
    required this.surname,
    required this.firstname,
    required this.middlename,
    this.active = true,
  });

  /// Full name in "FIRSTNAME MIDDLENAME SURNAME" format
  String get fullName {
    if (middlename.isEmpty) return '$firstname $surname';
    return '$firstname $middlename $surname';
  }

  /// Short display name: "FIRSTNAME SURNAME"
  String get displayName => '$firstname $surname';

  /// Initials from first letter of firstname and surname
  String get initials {
    final f = firstname.isNotEmpty ? firstname[0] : '';
    final s = surname.isNotEmpty ? surname[0] : '';
    return '$f$s';
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      surname: json['surname'] as String,
      firstname: json['firstname'] as String,
      middlename: (json['middlename'] as String?) ?? '',
      active: (json['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surname': surname,
      'firstname': firstname,
      'middlename': middlename,
      'active': active,
    };
  }

  Student copyWith({
    String? id,
    String? surname,
    String? firstname,
    String? middlename,
    bool? active,
  }) {
    return Student(
      id: id ?? this.id,
      surname: surname ?? this.surname,
      firstname: firstname ?? this.firstname,
      middlename: middlename ?? this.middlename,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) => other is Student && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Student($id, $fullName)';
}
