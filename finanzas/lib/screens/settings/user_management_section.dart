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
  List<User> _users = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await widget.userManager.getAllUsers();
    final currentUser = await widget.userManager.getCurrentUser();
    
    if (mounted) {
      setState(() {
        _users = users;
        _currentUser = currentUser;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            l10n.users,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color, 
            ),
          ),
        ),
        ..._users.map((user) {
          final isCurrentUser = _currentUser?.id == user.id;
          final isMainWallet = user.id == UserManager.getDefaultUserId();

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
  }

  Widget _buildUserTile(
    BuildContext context,
    User user,
    bool isCurrentUser,
    bool isMainWallet,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isCurrentUser 
          ? theme.colorScheme.primary.withOpacity(theme.brightness == Brightness.dark ? 0.1 : 0.05)
          : theme.cardColor,
      child: Stack(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () => _showImageOptions(context, user, l10n),
              child: _buildProfileAvatar(user),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      color: isCurrentUser ? theme.colorScheme.primary : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                if (isMainWallet)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(theme.brightness == Brightness.dark ? 0.4 : 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.principal,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.brightness == Brightness.dark ? Colors.lightGreenAccent : Colors.green,
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
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                if (!isMainWallet && !isCurrentUser)
                  Text(
                    l10n.holdToDelete,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.brightness == Brightness.dark ? Colors.orange[300] : Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditNameDialog(context, user, l10n),
                    tooltip: l10n.editUserName,
                  ),
                  if (!isCurrentUser)
                    IconButton(
                      icon: Icon(
                        Icons.check_circle_outline, 
                        size: 20, 
                        color: theme.colorScheme.primary, 
                      ),
                      onPressed: () async {
                        await widget.userManager.setCurrentUser(user);
                        widget.onUserChanged();
                        await _loadUsers();
                        if (mounted) {
                          widget.onShowSnackBar(
                            '${l10n.switchedTo} ${user.name}',
                            false,
                          );
                        }
                      },
                      tooltip: l10n.useThisWallet,
                    ),
                ],
              ),
            ),
            onTap: () async {
              if (isCurrentUser) {
                widget.onShowSnackBar(
                  l10n.alreadyUsingUser(user.name),
                  false,
                );
                return;
              }

              await widget.userManager.setCurrentUser(user);
              widget.onUserChanged();
              await _loadUsers();

              if (mounted) {
                widget.onShowSnackBar(
                  '${l10n.switchedTo} ${user.name}',
                  false,
                );
              }
            },
            onLongPress: !isMainWallet
                ? () => _showDeleteUserDialog(context, user, l10n)
                : null,
          ),
          if (!isMainWallet && !isCurrentUser)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(theme.brightness == Brightness.dark ? 0.7 : 0.5),
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
        backgroundImage: FileImage(File(user.profileImagePath!)),
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
        color:
            Colors.primaries[user.name.hashCode % Colors.primaries.length],
      ),
    );
  }

  void _showImageOptions(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) {
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

  Future<void> _pickImage(
    BuildContext context,
    User user,
    ImageSource source,
    AppLocalizations l10n,
  ) async {
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
        await _loadUsers();
        widget.onShowSnackBar(l10n.profilePhotoUpdated, false);
      }
    } catch (e) {
      widget.onShowSnackBar('${l10n.error}: $e', true);
    }
  }

  Future<void> _deleteProfileImage(
    User user,
    AppLocalizations l10n,
  ) async {
    await widget.userManager.deleteProfileImage(user.id);
    await _loadUsers();
    widget.onShowSnackBar(l10n.photoRemoved, false);
  }

  void _showEditNameDialog(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editUserName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.enterNewUserName,
            border: const OutlineInputBorder(),
          ),
          maxLength: 50,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == user.name) {
                Navigator.pop(dialogContext);
                return;
              }

              try {
                await widget.userManager.updateUserName(user.id, newName);
                
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                await _loadUsers();
                widget.onUserChanged();

                if (mounted) {
                  widget.onShowSnackBar(
                    l10n.nameUpdatedTo(newName),
                    false,
                  );
                }
              } catch (e) {
                widget.onShowSnackBar('${l10n.error}: $e', true);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final userName = controller.text.trim();
              if (userName.isEmpty) return;

              
              final newUserId = await widget.userManager.createUser(userName);
              final allUsers = await widget.userManager.getAllUsers();
              final newUser = allUsers.firstWhere((u) => u.id == newUserId);
              
              // Cambiar automáticamente al nuevo usuario
              await widget.userManager.setCurrentUser(newUser);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              await _loadUsers();

              
              widget.onUserChanged();
              
              if (mounted) {
                widget.onShowSnackBar(
                  '${l10n.userCreated}: $userName',
                  false,
                );
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(
    BuildContext context,
    User user,
    AppLocalizations l10n,
  ) {
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await widget.userManager.deleteUser(user.id);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                await _loadUsers();

                widget.onUserChanged();

                if (mounted) {
                  widget.onShowSnackBar(l10n.userDeleted, false);
                }
              } catch (e) {
                widget.onShowSnackBar('${l10n.error}: $e', true);
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}