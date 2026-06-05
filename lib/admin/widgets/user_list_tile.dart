import 'package:flutter/material.dart';
import 'package:rozgar/user/models/user_model.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const UserListTile({
    super.key,
    required this.user,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        child: Text((user.displayName ?? user.email)[0].toUpperCase()),
      ),
      title: Text(user.displayName ?? user.email),
      subtitle: Text(user.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(label: Text(user.role), visualDensity: VisualDensity.compact),
          const SizedBox(width: 4),
          Icon(
            Icons.circle,
            size: 12,
            color: user.isActive ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
