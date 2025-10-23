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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  
  static const String _isSignedInKey = 'google_drive_signed_in';

  bool get isSignedIn => _currentUser != null;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;
  String? get userPhotoUrl => _currentUser?.photoUrl;

  Future<void> initialize() async {
    debugPrint('🔄 Inicializando Google Drive Service...');
    
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

  Future<void> _saveSignInState(bool signedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSignedInKey, signedIn);
      debugPrint('💾 Estado guardado: signedIn=$signedIn');
    } catch (e) {
      debugPrint('❌ Error guardando estado: $e');
    }
  }

  Future<bool> _getSignInState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isSignedInKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error obteniendo estado: $e');
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      debugPrint('🔄 Iniciando sign in...');
      
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
      await _saveSignInState(false);
      return false;
    }
  }

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

  Future<bool> uploadBackup(
    Map<String, dynamic> data, {
    bool isAuto = false,
    String? customFileName,
  }) async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return false;
    }

    try {
      final jsonString = jsonEncode(data);
      final fileName = customFileName ?? 
          'finanzas_libre_${isAuto ? "auto" : "manual"}_${DateTime.now().millisecondsSinceEpoch}.json';

      debugPrint('🔄 Subiendo backup: $fileName');

      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/json'
        ..parents = ['root'];

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

  Future<List<DriveBackupFile>> listBackups() async {
    if (_driveApi == null) {
      debugPrint('❌ Drive API no inicializada');
      return [];
    }

    try {
      debugPrint('🔄 Listando backups...');
      
      final fileList = await _driveApi!.files.list(
        q: "name contains 'finanzas_libre_' and mimeType='application/json' and trashed=false",
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
}

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