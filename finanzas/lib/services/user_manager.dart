import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
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

  static Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _instance._ensureDefaultUserExists();
    _initialized = true;
  }

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

  Future<void> _saveUsers(List<User> users) async {
    final jsonList = users.map((u) => jsonEncode(u.toMap())).toList();
    await _prefs.setStringList(_usersKey, jsonList);
  }

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

  Future<User?> getCurrentUser() async {
    final users = await getAllUsers();
    final currentUserId = _prefs.getString(_currentUserKey) ?? _defaultUserId;

    try {
      return users.firstWhere((u) => u.id == currentUserId);
    } catch (e) {
      
      try {
        return users.firstWhere((u) => u.id == _defaultUserId);
      } catch (e) {
        return null;
      }
    }
  }

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

  Future<void> setCurrentUser(User user) async {
    await _prefs.setString(_currentUserKey, user.id);
  }

  

Future<String> createUser(String name) async {
  final users = await getAllUsers();

  final newUserId = DateTime.now().millisecondsSinceEpoch.toString();
  final newUser = User(
    id: newUserId,
    name: name,
    createdAt: DateTime.now(),
    profileImagePath: null,
  );

  await _saveUsers([...users, newUser]);
  
  
  return newUserId;
}

  Future<void> deleteUser(String userId) async {
    if (userId == _defaultUserId) {
      throw Exception('No se puede eliminar la billetera principal');
    }

    final users = await getAllUsers();
    final userToDelete = users.firstWhere((u) => u.id == userId);

    if (userToDelete.profileImagePath != null) {
      try {
        final file = File(userToDelete.profileImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error eliminando imagen: $e');
      }
    }

    
    users.removeWhere((u) => u.id == userId);
    await _saveUsers(users);

    
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

  
  Future<void> updateProfileImage(String userId, String imagePath) async {
    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex != -1) {
      users[userIndex] =
          users[userIndex].copyWith(profileImagePath: imagePath);
      await _saveUsers(users);
      debugPrint('✅ Imagen de perfil actualizada para usuario: $userId');
    }
  }

  
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
            debugPrint('✅ Imagen eliminada: $imagePath');
          }
        } catch (e) {
          debugPrint('❌ Error eliminando imagen: $e');
        }
      }

      users[userIndex] = users[userIndex].copyWith(profileImagePath: null);
      await _saveUsers(users);
      debugPrint('✅ Foto de perfil eliminada para usuario: $userId');
    }
  }

  
  Future<void> updateUserName(String userId, String newName) async {
    if (newName.trim().isEmpty) {
      throw Exception('El nombre no puede estar vacío');
    }

    final users = await getAllUsers();
    final userIndex = users.indexWhere((u) => u.id == userId);

    if (userIndex != -1) {
      users[userIndex] = users[userIndex].copyWith(name: newName.trim());
      await _saveUsers(users);
      debugPrint('✅ Nombre de usuario actualizado a: $newName');
    } else {
      throw Exception('Usuario no encontrado');
    }
  }

  // ============================================
  // MÉTODOS DE LIMPIEZA DE DATOS
  // ============================================

 
  Future<void> resetAppKeepingDefaultUser() async {
    final users = await getAllUsers();


    for (final user in users) {
      if (user.id != _defaultUserId) {
        
        if (user.profileImagePath != null) {
          try {
            final file = File(user.profileImagePath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            debugPrint('Error eliminando imagen: $e');
          }
        }
      }
    }

    final defaultUser =
        users.firstWhere((u) => u.id == _defaultUserId);
    await _saveUsers([defaultUser]);

    await setCurrentUser(defaultUser);
  }

  Future<User?> getDefaultUser() async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.id == _defaultUserId);
    } catch (e) {
      return null;
    }
  }

  static String getDefaultUserId() => _defaultUserId;

  static bool isDefaultUser(String userId) => userId == _defaultUserId;
}