import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_manager.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';

class UserSelectorMenu extends StatefulWidget {
  final UserManager userManager;
  final VoidCallback onUserChanged;
  final Function(String message, bool isError)? onShowSnackBar;

  const UserSelectorMenu({
    super.key,
    required this.userManager,
    required this.onUserChanged,
    this.onShowSnackBar,
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

  Future<void> _loadUsers() async {
    final currentUser = await widget.userManager.getCurrentUser();
    final allUsers = await widget.userManager.getAllUsers();
    
    if (mounted) {
      setState(() {
        _currentUser = currentUser;
        _allUsers = allUsers;
        _isLoading = false;
      });
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
    // Color que se adapta al modo: verde en claro, blanco en oscuro
    final highlightColor = isDarkMode ? Colors.white : theme.primaryColor;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
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
                        // Usamos el color adaptativo
                        color: isCurrentUser ? highlightColor : null,
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Icon(
                      Icons.check_circle,
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
        final selectedUser = _allUsers.firstWhere((u) => u.id == userId);
        
        await widget.userManager.setCurrentUser(selectedUser);
        widget.onUserChanged();
        
        await _loadUsers();
        
        if (mounted && widget.onShowSnackBar != null) {
          final l10n = AppLocalizations.of(context)!;
          widget.onShowSnackBar!(
            '${l10n.switchedTo} ${selectedUser.name}',
            false,
          );
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
                  // Color blanco en modo oscuro para mejor legibilidad
                  color: isDarkMode ? Colors.white : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: isDarkMode ? Colors.white : theme.textTheme.labelSmall?.color,
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
      backgroundColor: Colors.primaries[user.name.hashCode % Colors.primaries.length]
            .withOpacity(0.3),
      child: Icon(
        Icons.person,
        color: Colors.primaries[user.name.hashCode % Colors.primaries.length],
        size: size * 0.6,
      ),
    );
  }
}