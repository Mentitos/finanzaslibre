import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../l10n/app_localizations.dart';
import 'dart:io';

class UserManagementSection extends StatefulWidget {
  final UserManager userManager;
  final VoidCallback onUserChanged;
  final Function(String message, bool isError) onShowSnackBar;

  const UserManagementSection({
    super.key,
    required this.userManager,
    required this.onUserChanged,
    required this.onShowSnackBar,
  });

  @override
  State<UserManagementSection> createState() => _UserManagementSectionState();
}

class _UserManagementSectionState extends State<UserManagementSection> {
  Future<List<User>>? _usersFuture;


    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa el Future si aún no ha sido cargado
    if (_usersFuture == null) {
      _usersFuture = widget.userManager.getAllUsers();
    }
  }

   @override
  void didUpdateWidget(covariant UserManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aunque el UserListPage es un StatelessWidget, a veces los cambios en los props 
    // se propagan. No es estrictamente necesario, pero ayuda a la robustez.
    if (widget.userManager != oldWidget.userManager) {
      _usersFuture = widget.userManager.getAllUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.users,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
        ),
        FutureBuilder<List<User>>(
   future: _usersFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = snapshot.data!;
    return Column(
      children: [
              ...users.map((user) {
                final isCurrentUser =
                    widget.userManager.getCurrentUser()?.id == user.id;
                final isMainWallet = user.id == 'default_user';

                return _buildUserTile(
                  context,
                  user,
                  isCurrentUser,
                  isMainWallet,
                  l10n,
                );
              }),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context, l10n),
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.addUser),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
    );
  },
)

      ],
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    User user,
    bool isCurrentUser,
    bool isMainWallet,
    AppLocalizations l10n,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Stack(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => _showImageOptions(context, user, l10n),
              child: _buildProfileAvatar(user),
            ),
            title: Row(
              children: [
                Expanded(child: Text(user.name)),
                if (isMainWallet)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.principal,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isCurrentUser)
                  Text(
                    l10n.currentUser,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (!isMainWallet && !isCurrentUser)
                  Text(
                    'Presiona y mantén para eliminar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            // Modificar el onTap en _buildUserTile:

onTap: () async {
    // Si ya es el usuario actual, no hacemos nada y simplemente retornamos.
    if (isCurrentUser) {
        widget.onShowSnackBar('Ya estabas usando ${user.name}', false);
        return; 
    }
    
    // Lógica para cambiar de usuario:
    await widget.userManager.setCurrentUser(user);
    widget.onUserChanged();
    setState(() {});
    
    if (mounted) {
        widget.onShowSnackBar(
            '${l10n.switchedTo} ${user.name}', false);
    }
},
            onLongPress: !isMainWallet
                ? () => _showDeleteUserDialog(context, user, l10n)
                : null,
          ),
          // Mostrar indicador visual si es eliminable
          if (!isMainWallet && !isCurrentUser)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(User user) {
    if (user.profileImagePath != null) {
      return CircleAvatar(
        backgroundImage: FileImage(
          // ignore: unnecessary_cast
          File(user.profileImagePath!),
        ),
        radius: 24,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.primaries[user.name.hashCode % Colors.primaries.length]
            .withOpacity(0.3),
      ),
      child: Icon(
        Icons.person,
        color: Colors.primaries[user.name.hashCode % Colors.primaries.length],
      ),
    );
  }

  void _showImageOptions(BuildContext context, User user, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, user, ImageSource.camera, l10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, user, ImageSource.gallery, l10n);
              },
            ),
            if (user.profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.removePhoto),
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage(user, l10n);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, User user, ImageSource source,
      AppLocalizations l10n) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (pickedFile != null && mounted) {
        await widget.userManager.updateProfileImage(user.id, pickedFile.path);
        setState(() {});
        widget.onShowSnackBar(l10n.profilePhotoUpdated, false);
      }
    } catch (e) {
      widget.onShowSnackBar('${l10n.error}: $e', true);
    }
  }

  Future<void> _deleteProfileImage(User user, AppLocalizations l10n) async {
    await widget.userManager.deleteProfileImage(user.id);
    setState(() {});
    widget.onShowSnackBar(l10n.photoRemoved, false);
  }

  void _showAddUserDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addUser),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.enterUserName,
            border: const OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Usar dialogContext
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              // ... lógica de validación ...

              final userName = controller.text.trim();
              await widget.userManager.createUser(userName);
              
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); 
              }

              setState(
                  () => _usersFuture = widget.userManager.getAllUsers());

              // 🌟 CORRECCIÓN 1: Llama a onUserChanged al crear un usuario.
              // Esto forzará la recarga de datos en la pantalla principal.
              widget.onUserChanged(); 

              if (mounted) {
                setState(() {});
                widget.onShowSnackBar(
                    '${l10n.userCreated}: $userName', false);
              }
            },
            child: Text(l10n.create),
            
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(
      BuildContext context, User user, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteUser),
        content: Text('${l10n.deleteUserConfirmation} "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await widget.userManager.deleteUser(user.id);
              
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); 
              }

              setState(
                  () => _usersFuture = widget.userManager.getAllUsers());

              if (mounted) {
                setState(() {});
                widget.onShowSnackBar(l10n.userDeleted, false);
                
                // 🌟 CORRECCIÓN 2: Llama a onUserChanged al eliminar un usuario.
                // Esto es fundamental si el usuarioManager cambia de usuario activo
                // automáticamente después de una eliminación (ej. vuelve al default).
                widget.onUserChanged();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}