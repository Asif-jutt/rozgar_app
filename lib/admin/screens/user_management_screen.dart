import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/admin/providers/user_management_provider.dart';
import 'package:rozgar/admin/widgets/user_list_tile.dart';
import 'package:rozgar/user/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = UserManagementProvider.to;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminStrings.users),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              onChanged: (v) => provider.searchQuery.value = v,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['all', 'jobSeeker', 'employer', 'banned']
                  .map((f) => Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(f),
                          selected: provider.roleFilter.value == f,
                          onSelected: (_) => provider.roleFilter.value = f,
                        ),
                      )))
                  .toList(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (provider.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = provider.filteredUsers;
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => UserListTile(
                  user: list[i],
                  onLongPress: () => _showActions(context, list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, UserModel user) {
    Get.bottomSheet(
      Wrap(
        children: [
          if (user.isActive)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text(AdminStrings.banUser),
              onTap: () {
                Get.back();
                UserManagementProvider.to.banUser(user.uid, 'Admin action');
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text(AdminStrings.unbanUser),
              onTap: () {
                Get.back();
                UserManagementProvider.to.unbanUser(user.uid);
              },
            ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            onTap: () {
              Get.back();
              Get.dialog(AlertDialog(
                title: Text(user.displayName ?? user.email),
                content: Text(
                  'Email: ${user.email}\nRole: ${user.role}\nPremium: ${user.isPremium}',
                ),
              ));
            },
          ),
        ],
      ),
    );
  }
}
