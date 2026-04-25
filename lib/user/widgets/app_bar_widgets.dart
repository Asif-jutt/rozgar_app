import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.onMenuPressed,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor = AppColors.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.headline4.copyWith(color: Colors.white),
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
      elevation: 8,
      showUnselectedLabels: true,
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

class UserDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const UserDrawer({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          Container(
            decoration: const BoxDecoration(color: AppColors.primaryColor),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.secondaryColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.verticalSpaceMedium),
                Text(
                  userName,
                  style: AppTextStyles.headline4.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Navigation Items
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: AppStrings.home,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.search,
            title: AppStrings.findJobs,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: AppStrings.myProfile,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/myprofile');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.assignment,
            title: AppStrings.myApplications,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/myapplication');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.edit,
            title: AppStrings.buildProfile,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buildprofile');
            },
          ),

          const Divider(height: AppDimensions.paddingMedium, thickness: 1),

          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: AppStrings.settings,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: AppStrings.logout,
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
            isRed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? AppColors.errorColor : AppColors.primaryColor,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isRed ? AppColors.errorColor : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
