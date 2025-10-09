import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../l10n/app_localizations.dart';

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
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.userManager.getAllUsers();
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
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
        subtitle: isCurrentUser ? Text(l10n.currentUser) : null,
        trailing: isCurrentUser
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: isCurrentUser
            ? null
            : () async {
                await widget.userManager.setCurrentUser(user);
                widget.onUserChanged();
                setState(() => _usersFuture =
                    widget.userManager.getAllUsers());
                if (mounted) {
                  widget.onShowSnackBar(
                      '${l10n.switchedTo} ${user.name}', false);
                }
              },
        onLongPress: !isMainWallet && !isCurrentUser
            ? () => _showDeleteUserDialog(context, user, l10n)
            : null,
      ),
    );
  }

  Widget _buildProfileAvatar(User user) {
    if (user.profileImagePath != null) {
      return CircleAvatar(
        backgroundImage: FileImage(
          // ignore: unnecessary_cast
          (user.profileImagePath) as dynamic,
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
        setState(() => _usersFuture = widget.userManager.getAllUsers());
        widget.onShowSnackBar(l10n.profilePhotoUpdated, false);
      }
    } catch (e) {
      widget.onShowSnackBar('${l10n.error}: $e', true);
    }
  }

  Future<void> _deleteProfileImage(User user, AppLocalizations l10n) async {
    await widget.userManager.deleteProfileImage(user.id);
    setState(() => _usersFuture = widget.userManager.getAllUsers());
    widget.onShowSnackBar(l10n.photoRemoved, false);
  }

  void _showAddUserDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                widget.onShowSnackBar(l10n.enterUserName, true);
                return;
              }

              final userName = controller.text.trim();
              await widget.userManager.createUser(userName);
              setState(
                  () => _usersFuture = widget.userManager.getAllUsers());

              if (mounted) {
                Navigator.pop(context);
                // Mostrar mensaje de éxito
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
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteUser),
        content: Text('${l10n.deleteUserConfirmation} "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await widget.userManager.deleteUser(user.id);
              widget.onUserChanged();
              setState(
                  () => _usersFuture = widget.userManager.getAllUsers());

              if (mounted) {
                Navigator.pop(context);
                widget.onShowSnackBar(l10n.userDeleted, false);
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