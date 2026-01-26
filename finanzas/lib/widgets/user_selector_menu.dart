import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_manager.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';

class UserSelectorMenu extends StatefulWidget {
  final UserManager userManager;
  final VoidCallback onUserChanged;
  final Function(String message, bool isError)? onShowSnackBar;

  final Key? refreshKey;

  const UserSelectorMenu({
    super.key,
    required this.userManager,
    required this.onUserChanged,
    this.onShowSnackBar,
    this.refreshKey,
  });

  @override
  State<UserSelectorMenu> createState() => _UserSelectorMenuState();
}

class _UserSelectorMenuState extends State<UserSelectorMenu> {
  User? _currentUser;
  List<User> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didUpdateWidget(UserSelectorMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshKey != widget.refreshKey) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    try {
      final currentUser = await widget.userManager.getCurrentUser();
      final allUsers = await widget.userManager.getAllUsers();

      if (mounted) {
        setState(() {
          _currentUser = currentUser;
          _allUsers = allUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUser == null) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final highlightColor = isDarkMode ? Colors.white : theme.primaryColor;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      surfaceTintColor: Colors.transparent,
      itemBuilder: (context) {
        return _allUsers.map((user) {
          final isCurrentUser = user.id == _currentUser?.id;

          return PopupMenuItem<String>(
            value: user.id,
            enabled: !isCurrentUser,
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              child: Row(
                children: [
                  _buildUserAvatar(user, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: isCurrentUser
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : (isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Icon(
                      Icons.check_circle,
                      // Mantenemos el color primario/rosa solo para el check, o usamos contraste también
                      // El usuario pidió contraste en el texto/fondo. El check puede ser de color.
                      color: highlightColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      onSelected: (userId) async {
        try {
          final l10n = AppLocalizations.of(context)!;
          final selectedUser = _allUsers.firstWhere((u) => u.id == userId);

          await widget.userManager.setCurrentUser(selectedUser);
          widget.onUserChanged();

          await _loadUsers();

          if (!mounted) return;

          if (widget.onShowSnackBar != null) {
            widget.onShowSnackBar!(
              '${l10n.switchedTo} ${selectedUser.name}',
              false,
            );
          }
        } catch (e) {
          debugPrint('Error selecting user: $e');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserAvatar(_currentUser!, size: 16),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                _currentUser!.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: theme.appBarTheme.foregroundColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: theme.appBarTheme.foregroundColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(User user, {required double size}) {
    if (user.profileImagePath != null) {
      return CircleAvatar(
        backgroundImage: FileImage(File(user.profileImagePath!)),
        radius: size / 2,
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors
          .primaries[user.name.hashCode % Colors.primaries.length]
          .withValues(alpha: 0.3),
      child: Icon(
        Icons.person,
        color: Colors.primaries[user.name.hashCode % Colors.primaries.length],
        size: size * 0.6,
      ),
    );
  }
}
