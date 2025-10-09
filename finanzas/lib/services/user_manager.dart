import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class UserManager {
  static const String _usersKey = 'users_list';
  static const String _currentUserIdKey = 'current_user_id';
  static const String _defaultUserId = 'default_user';

  late SharedPreferences _prefs;
  User? _currentUser;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _ensureDefaultUser();
    await _loadCurrentUser();
  }

  // Garantizar que existe un usuario por defecto
  Future<void> _ensureDefaultUser() async {
    final users = await getAllUsers();
    if (users.isEmpty) {
      final defaultUser = User(
        id: _defaultUserId,
        name: 'Mi Billetera',
        createdAt: DateTime.now(),
      );
      await _saveUser(defaultUser);
      await _setCurrentUser(defaultUser);
    }
  }

  // Obtener todos los usuarios
  Future<List<User>> getAllUsers() async {
    try {
      final usersJson = _prefs.getStringList(_usersKey) ?? [];
      return usersJson
          .map((json) => User.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  // Obtener usuario actual
  User? getCurrentUser() => _currentUser;

  // Cargar usuario actual desde preferencias
  Future<void> _loadCurrentUser() async {
    final currentUserId = _prefs.getString(_currentUserIdKey);
    if (currentUserId != null) {
      final users = await getAllUsers();
      try {
        _currentUser = users.firstWhere(
          (user) => user.id == currentUserId,
        );
      } catch (e) {
        _currentUser = users.isNotEmpty ? users.first : null;
        if (_currentUser != null) {
          await _prefs.setString(_currentUserIdKey, _currentUser!.id);
        }
      }
    } else {
      final users = await getAllUsers();
      if (users.isNotEmpty) {
        _currentUser = users.first;
        await _prefs.setString(_currentUserIdKey, _currentUser!.id);
      }
    }
  }

  // Crear nuevo usuario
  Future<User> createUser(String name) async {
    final newUser = User(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _saveUser(newUser);
    return newUser;
  }

  // Guardar usuario
  Future<void> _saveUser(User user) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }

    final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
    await _prefs.setStringList(_usersKey, usersJson);
  }

  // Actualizar usuario
  Future<void> updateUser(User user) async {
    await _saveUser(user);
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
  }

  // Establecer usuario actual
  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    await _prefs.setString(_currentUserIdKey, user.id);
  }

  // Alias para compatibilidad
  Future<void> _setCurrentUser(User user) => setCurrentUser(user);

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    // ✅ IMPORTANTE: Proteger la billetera principal
    if (userId == _defaultUserId) {
      throw Exception('Cannot delete main wallet');
    }

    final users = await getAllUsers();
    users.removeWhere((user) => user.id == userId);

    final usersJson = users.map((u) => jsonEncode(u.toJson())).toList();
    await _prefs.setStringList(_usersKey, usersJson);

    // Si eliminamos el usuario actual, cambiar a la billetera principal
    if (_currentUser?.id == userId) {
      final mainUser = users.firstWhere(
        (u) => u.id == _defaultUserId,
        orElse: () => users.isNotEmpty ? users.first : User(
          id: _defaultUserId,
          name: 'Mi Billetera',
          createdAt: DateTime.now(),
        ),
      );
      await setCurrentUser(mainUser);
    }
  }

  // Actualizar foto de perfil
  Future<void> updateProfileImage(String userId, String imagePath) async {
    final user = await getUserById(userId);
    if (user != null) {
      await updateUser(user.copyWith(profileImagePath: imagePath));
    }
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String userId) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Eliminar foto de perfil
  Future<void> deleteProfileImage(String userId) async {
    final user = await getUserById(userId);
    if (user != null && user.profileImagePath != null) {
      try {
        final file = File(user.profileImagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting image: $e');
      }
      await updateUser(user.copyWith(profileImagePath: null));
    }
  }
}