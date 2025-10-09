class User {
  final String id;
  final String name;
  final String? profileImagePath;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.profileImagePath,
    required this.createdAt,
  });

  // Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImagePath': profileImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImagePath: json['profileImagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Crear copia con cambios
  User copyWith({
    String? id,
    String? name,
    String? profileImagePath,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}