enum UserRole {
  admin,
  student;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.student:
        return 'Mahasiswa';
    }
  }

  String get firestoreValue => name;
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.nim,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String nim;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nim': nim,
      'email': email,
      'role': role.firestoreValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
