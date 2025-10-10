class User {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? profileImagePath;

  User({
    required this.id,
    required this.name,
    required this.createdAt,
    this.profileImagePath,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      profileImagePath: map['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'profileImagePath': profileImagePath,
    };
  }

  User copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name)';
}