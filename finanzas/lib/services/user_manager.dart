// ============================================
// ARCHIVO: services/user_manager.dart
// ============================================
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static const String _usersKey = 'users_list';
  static const String _currentUserKey = 'current_user_id';
  static const String _defaultUserId = 'default_user';

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  /// Inicializar el UserManager - debe llamarse al inicio de la app
  static Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _instance._ensureDefaultUserExists();
    _initialized = true;
  }

  /// Asegura que el usuario por defecto siempre exista
  Future<void> _ensureDefaultUserExists() async {
    final users = await getAllUsers();

    final hasDefault = users.any((u) => u.id == _defaultUserId);

    if (!hasDefault) {
      final defaultUser = User(
        id: _defaultUserId,
        name: 'Mi Billetera',
        createdAt: DateTime.now(),
        profileImagePath: null,
      );

      await _saveUsers([...users, defaultUser]);
      await setCurrentUser(defaultUser);
    }
  }

  /// Guardar lista de usuarios en SharedPreferences
  Future<void> _saveUsers(List<User> users) async {
    final jsonList = users.map((u) => jsonEncode(u.toMap())).toList();
    await _prefs.setStringList(_usersKey, jsonList);
  }

  /// Obtener usuario actual SIN async (para sincronía)
  User? getCurrentUserSync() {
    try {
      final jsonList = _prefs.getStringList(_usersKey) ?? [];
      final users = jsonList
          .map((json) {
            final map = jsonDecode(json) as Map<String, dynamic>;
            return User.fromMap(map);
          })
          .toList();

      final currentUserId = _prefs.getString(_currentUserKey) ?? _defaultUserId;

      return users.firstWhere((u) => u.id == currentUserId);
    } catch (e) {
      try {
        final jsonList = _prefs.getStringList(_usersKey) ?? [];
        final users = jsonList
            .map((json) {
              final map = jsonDecode(json) as Map<String, dynamic>;
              return User.fromMap(map);
            })
            .toList();
        return users.firstWhere((u) => u.id == _defaultUserId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    final jsonList = _prefs.getStringList(_usersKey) ?? [];
    return jsonList
        .map((json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          return User.fromMap(map);
        })
        .toList()
        .cast<User>();
  }

  /// Obtener usuario actual
  Future<User?> getCurrentUser() async {
    final users = await getAllUsers();
    final currentUserId = _prefs.getString(_currentUserKey) ?? _defaultUserId;

    try {
      return users.firstWhere((u) => u.id == currentUserId);
    } catch (e) {
      // Si no encuentra el usuario, devuelve el por defecto
      try {
        return users.firstWhere((u) => u.id == _defaultUserId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Establecer usuario actual
  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_currentUserKey, user.id);
  }

  /// Crear nuevo usuario
  Future<void> createUser(String name) async {
    final users = await getAllUsers();

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      profileImagePath: null,
    );

    await _saveUsers([...users, newUser]);
  }

  /// Eliminar usuario (excepto el usuario por defecto)
  Future<void> deleteUser(String userId) async {
    if (userId == _defaultUserId) {
      throw Exception('No se puede eliminar la billetera principal');
    }

    final users = await getAllUsers();
    final userToDelete = users.firstWhere((u) => u.id == userId);

    // Eliminar imagen de perfil si existe
    if (userToDelete.profileImagePath != null) {
      try {
        final file = File(userToDelete.profileImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error eliminando imagen: $e');
      }
    }

    // Eliminar usuario de la lista
    users.removeWhere((u) => u.id == userId);
    await _saveUsers(users);

    // Si el usuario eliminado era el actual, cambiar al usuario por defecto
    final currentUser = await getCurrentUser();
    if (currentUser?.id == userId) {
      final defaultUser = users.firstWhere((u) => u.id == _defaultUserId,
          orElse: () => users.isNotEmpty ? users.first : User(
            id: _defaultUserId,
            name: 'Mi Billetera',
            createdAt: DateTime.now(),
          ));
      await setCurrentUser(defaultUser);
    }
  }

  /// Actualizar imagen de perfil
  Future<void> updateProfileImage(String userId, String imagePath) async {
    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex != -1) {
      users[userIndex] =
          users[userIndex].copyWith(profileImagePath: imagePath);
      await _saveUsers(users);
    }
  }

  /// Eliminar imagen de perfil
  Future<void> deleteProfileImage(String userId) async {
    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex != -1) {
      final imagePath = users[userIndex].profileImagePath;

      if (imagePath != null) {
        try {
          final file = File(imagePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error eliminando imagen: $e');
        }
      }

      users[userIndex] = users[userIndex].copyWith(profileImagePath: null);
      await _saveUsers(users);
    }
  }

  // ============================================
  // MÉTODOS DE LIMPIEZA DE DATOS
  // ============================================

  /// Reset de la app manteniendo la billetera principal
  /// - Elimina todos los usuarios excepto el por defecto
  /// - Elimina todos los datos (registros, categorías, etc.)
  /// - Mantiene el usuario por defecto pero sin datos
  Future<void> resetAppKeepingDefaultUser() async {
    final users = await getAllUsers();

    // Eliminar todos los usuarios excepto el por defecto
    for (final user in users) {
      if (user.id != _defaultUserId) {
        // Eliminar imagen de perfil si existe
        if (user.profileImagePath != null) {
          try {
            final file = File(user.profileImagePath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print('Error eliminando imagen: $e');
          }
        }
      }
    }

    // Mantener solo el usuario por defecto
    final defaultUser =
        users.firstWhere((u) => u.id == _defaultUserId);
    await _saveUsers([defaultUser]);

    // Asegurar que el usuario por defecto sea el actual
    await setCurrentUser(defaultUser);
  }

  /// Obtener información del usuario por defecto
  Future<User?> getDefaultUser() async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == _defaultUserId);
    } catch (e) {
      return null;
    }
  }

  /// Obtener ID del usuario por defecto
  static String getDefaultUserId() => _defaultUserId;

  /// Verificar si un usuario es el por defecto
  static bool isDefaultUser(String userId) => userId == _defaultUserId;
}

// ============================================
// ARCHIVO: models/user_model.dart (asegúrate de que tenga esto)
// ============================================
// class User {
//   final String id;
//   final String name;
//   final DateTime createdAt;
//   final String? profileImagePath;
//
//   User({
//     required this.id,
//     required this.name,
//     required this.createdAt,
//     this.profileImagePath,
//   });
//
//   factory User.fromMap(Map<String, dynamic> map) {
//     return User(
//       id: map['id'] as String,
//       name: map['name'] as String,
//       createdAt: DateTime.parse(map['createdAt'] as String),
//       profileImagePath: map['profileImagePath'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'createdAt': createdAt.toIso8601String(),
//       'profileImagePath': profileImagePath,
//     };
//   }
//
//   User copyWith({
//     String? id,
//     String? name,
//     DateTime? createdAt,
//     String? profileImagePath,
//   }) {
//     return User(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       createdAt: createdAt ?? this.createdAt,
//       profileImagePath: profileImagePath ?? this.profileImagePath,
//     );
//   }
//
//   @override
//   String toString() => 'User(id: $id, name: $name)';
// }