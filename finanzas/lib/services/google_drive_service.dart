import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Configuración de Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveFileScope, // Acceso completo a archivos creados por la app
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Getters
  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;

  /// Inicializar el servicio
  Future<void> initialize() async {
    // Escuchar cambios en el estado de autenticación
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });

    // Intentar iniciar sesión silenciosamente
    await _googleSignIn.signInSilently();
  }

  /// Iniciar sesión con Google
  Future<bool> signIn() async {
    try {
      // Desconectar primero para forzar selección de cuenta
      await _googleSignIn.signOut();
      
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('❌ Usuario canceló el inicio de sesión');
        return false;
      }

      _currentUser = account;
      await _initializeDriveApi();
      
      debugPrint('✅ Inicio de sesión exitoso: ${account.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Error al iniciar sesión: $e');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');
      
      // Dar más información sobre el error
      if (e.toString().contains('10:')) {
        debugPrint('❌ Error 10: Verifica que hayas configurado OAuth en Google Cloud Console');
        debugPrint('❌ Asegúrate de que el SHA-1 esté registrado correctamente');
      }
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      debugPrint('✅ Sesión cerrada');
    } catch (e) {
      debugPrint('❌ Error al cerrar sesión: $e');
    }
  }

  /// Inicializar Drive API
  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) return;

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

      // Crear metadata del archivo
      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json'
        ..parents = ['root']; // Guardar en la raíz de Drive

      // Convertir JSON a Stream
      final mediaStream = Stream.value(utf8.encode(jsonString));
      final media = drive.Media(mediaStream, jsonString.length);

      // Subir archivo
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
      final fileList = await _driveApi!.files.list(
        q: "name contains 'finanzas_libre_backup_' and mimeType='application/json'",
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
        return true; // No es necesario crear otro backup
      }

      // Crear nuevo backup
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
    return '${createdTime!.day}/${createdTime!.month}/${createdTime!.year} ${createdTime!.hour}:${createdTime!.minute}';
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