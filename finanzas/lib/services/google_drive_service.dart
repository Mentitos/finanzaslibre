import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Configuración de Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  
  // ✅ Clave para guardar estado de sesión
  static const String _isSignedInKey = 'google_drive_signed_in';

  // Getters
  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;

  /// Inicializar el servicio
  Future<void> initialize() async {
    debugPrint('🔄 Inicializando Google Drive Service...');
    
    // Escuchar cambios en el estado de autenticación
    _googleSignIn.onCurrentUserChanged.listen((account) async {
      _currentUser = account;
      
      if (account != null) {
        await _initializeDriveApi();
        await _saveSignInState(true);
        debugPrint('✅ Usuario autenticado: ${account.email}');
      } else {
        await _saveSignInState(false);
        debugPrint('❌ Usuario desconectado');
      }
    });

    // ✅ Intentar restaurar sesión anterior
    final wasSignedIn = await _getSignInState();
    
    if (wasSignedIn) {
      debugPrint('🔄 Intentando restaurar sesión...');
      try {
        final account = await _googleSignIn.signInSilently();
        if (account != null) {
          debugPrint('✅ Sesión restaurada: ${account.email}');
        } else {
          debugPrint('⚠️ No se pudo restaurar la sesión');
          await _saveSignInState(false);
        }
      } catch (e) {
        debugPrint('❌ Error restaurando sesión: $e');
        await _saveSignInState(false);
      }
    } else {
      debugPrint('ℹ️ No hay sesión previa');
    }
  }

  /// Guardar estado de sesión
  Future<void> _saveSignInState(bool signedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSignedInKey, signedIn);
      debugPrint('💾 Estado guardado: signedIn=$signedIn');
    } catch (e) {
      debugPrint('❌ Error guardando estado: $e');
    }
  }

  /// Obtener estado de sesión
  Future<bool> _getSignInState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isSignedInKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error obteniendo estado: $e');
      return false;
    }
  }

  /// Iniciar sesión con Google
  Future<bool> signIn() async {
    try {
      debugPrint('🔄 Iniciando sign in...');
      
      // ✅ NO desconectar antes - esto causa problemas
      // await _googleSignIn.signOut();
      
      final account = await _googleSignIn.signIn();
      
      if (account == null) {
        debugPrint('❌ Usuario canceló el inicio de sesión');
        await _saveSignInState(false);
        return false;
      }

      _currentUser = account;
      await _initializeDriveApi();
      await _saveSignInState(true);
      
      debugPrint('✅ Inicio de sesión exitoso: ${account.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Error al iniciar sesión: $e');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');
      
      if (e.toString().contains('10:') || e.toString().contains('DEVELOPER_ERROR')) {
        debugPrint('❌ Error 10 (DEVELOPER_ERROR): Verifica tu configuración de OAuth');
        debugPrint('   - Asegúrate de que el SHA-1 esté registrado correctamente');
        debugPrint('   - Verifica que el package name coincida');
        debugPrint('   - Revisa que OAuth Client ID esté configurado');
      }
      
      await _saveSignInState(false);
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      await _saveSignInState(false);
      debugPrint('✅ Sesión cerrada');
    } catch (e) {
      debugPrint('❌ Error al cerrar sesión: $e');
    }
  }

  /// Inicializar Drive API
  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) {
      debugPrint('⚠️ No hay usuario para inicializar Drive API');
      return;
    }

    try {
      final authHeaders = await _currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticateClient);
      debugPrint('✅ Drive API inicializada');
    } catch (e) {
      debugPrint('❌ Error inicializando Drive API: $e');
    }
  }

  /// Subir datos JSON a Google Drive
  Future<bool> uploadBackup(Map<String, dynamic> data) async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return false;
    }

    try {
      final jsonString = jsonEncode(data);
      final fileName = 'finanzas_libre_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      debugPrint('🔄 Subiendo backup: $fileName');

      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json'
        ..parents = ['root'];

      // ✅ FIX: Convertir a bytes primero para obtener el tamaño exacto
      final bytes = utf8.encode(jsonString);
      final mediaStream = Stream.value(bytes);
      final media = drive.Media(mediaStream, bytes.length);

      debugPrint('📦 Tamaño del backup: ${bytes.length} bytes');

      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      debugPrint('✅ Backup subido: ${uploadedFile.id} - $fileName');
      return true;
    } catch (e) {
      debugPrint('❌ Error subiendo backup: $e');
      return false;
    }
  }

  /// Listar todos los backups disponibles
  Future<List<DriveBackupFile>> listBackups() async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return [];
    }

    try {
      debugPrint('🔄 Listando backups...');
      
      final fileList = await _driveApi!.files.list(
        q: "name contains 'finanzas_libre_backup_' and mimeType='application/json' and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'drive',
        $fields: 'files(id, name, createdTime, size)',
      );

      final backups = fileList.files?.map((file) {
        return DriveBackupFile(
          id: file.id ?? '',
          name: file.name ?? '',
          createdTime: file.createdTime,
          size: file.size != null ? int.tryParse(file.size!) : null,
        );
      }).toList() ?? [];

      debugPrint('✅ ${backups.length} backups encontrados');
      return backups;
    } catch (e) {
      debugPrint('❌ Error listando backups: $e');
      return [];
    }
  }

  /// Descargar backup desde Google Drive
  Future<Map<String, dynamic>?> downloadBackup(String fileId) async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return null;
    }

    try {
      debugPrint('🔄 Descargando backup: $fileId');
      
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final dataBytes = <int>[];
      await for (var chunk in media.stream) {
        dataBytes.addAll(chunk);
      }

      final jsonString = utf8.decode(dataBytes);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      debugPrint('✅ Backup descargado: $fileId');
      return data;
    } catch (e) {
      debugPrint('❌ Error descargando backup: $e');
      return null;
    }
  }

  /// Eliminar backup de Google Drive
  Future<bool> deleteBackup(String fileId) async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return false;
    }

    try {
      debugPrint('🔄 Eliminando backup: $fileId');
      await _driveApi!.files.delete(fileId);
      debugPrint('✅ Backup eliminado: $fileId');
      return true;
    } catch (e) {
      debugPrint('❌ Error eliminando backup: $e');
      return false;
    }
  }

  /// Sincronización automática (subir si hay cambios)
  Future<bool> autoSync(Map<String, dynamic> data) async {
    if (!isSignedIn) {
      debugPrint('⚠️ No hay sesión activa para auto-sync');
      return false;
    }

    try {
      debugPrint('🔄 Auto-sync iniciado...');
      
      // Verificar si hay backups recientes (últimas 24 horas)
      final backups = await listBackups();
      final now = DateTime.now();
      
      final recentBackup = backups.any((backup) {
        if (backup.createdTime == null) return false;
        final difference = now.difference(backup.createdTime!);
        return difference.inHours < 24;
      });

      if (recentBackup) {
        debugPrint('ℹ️ Ya existe un backup reciente (menos de 24h)');
        return true;
      }

      // Crear nuevo backup
      debugPrint('🔄 Creando nuevo backup automático...');
      return await uploadBackup(data);
    } catch (e) {
      debugPrint('❌ Error en auto-sync: $e');
      return false;
    }
  }
}

/// Modelo para representar un archivo de backup en Drive
class DriveBackupFile {
  final String id;
  final String name;
  final DateTime? createdTime;
  final int? size;

  DriveBackupFile({
    required this.id,
    required this.name,
    this.createdTime,
    this.size,
  });

  String get formattedDate {
    if (createdTime == null) return 'Fecha desconocida';
    final day = createdTime!.day.toString().padLeft(2, '0');
    final month = createdTime!.month.toString().padLeft(2, '0');
    final year = createdTime!.year;
    final hour = createdTime!.hour.toString().padLeft(2, '0');
    final minute = createdTime!.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String get formattedSize {
    if (size == null) return 'Tamaño desconocido';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Cliente HTTP para autenticación con Google
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}