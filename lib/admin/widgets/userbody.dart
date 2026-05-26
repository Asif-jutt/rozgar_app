import 'package:flutter/material.dart';
import 'package:rozgar/user/models/app_user.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';

class UserBody extends StatefulWidget {
  const UserBody({super.key});

  @override
  State<UserBody> createState() => _UserBodyState();
}

class _UserBodyState extends State<UserBody> {
  final _firestore = FirestoreService();
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      future: _firestore.getAllUsers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = snap.data ?? [];
        if (_roleFilter != 'all') {
          users = users.where((u) => u.userRole == _roleFilter).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'seeker', label: Text('Seekers')),
                  ButtonSegment(value: 'company', label: Text('Companies')),
                ],
                selected: {_roleFilter},
                onSelectionChanged: (s) => setState(() => _roleFilter = s.first),
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('No users'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, i) {
                        final u = users[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: ProfileAvatar(
                              imageUrl: u.profileImageUrl,
                              radius: 22,
                              fallbackText: u.name,
                            ),
                            title: Text(u.name),
                            subtitle: Text('${u.email} • ${u.userRole}'),
                            trailing: u.userRole == 'admin'
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.errorColor),
                                    onPressed: () async {
                                      await _firestore.deleteUserDoc(u.uid);
                                      setState(() {});
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}


