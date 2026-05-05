import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/localization/app_localizations.dart';
import 'edit_profile_screen.dart';
import 'dev_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final stats = userProvider.stats;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n('profile')),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                tooltip: 'Edit Profile',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DevSettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Header
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.lightTeal,
                  backgroundImage: user?.avatarUrl != null 
                    ? NetworkImage(user!.avatarUrl!) 
                    : null,
                  child: user?.avatarUrl == null 
                    ? const Icon(Icons.person, size: 50, color: AppColors.primaryTeal)
                    : null,
                ),

                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Student',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  '${user?.grade ?? 'Class 10'} - ${user?.board ?? 'Lahore Board'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      _buildStatCard(context.l10n('tests'), '${stats?.testsTaken ?? 0}'),
                      const SizedBox(width: 16),
                      _buildStatCard(context.l10n('correct'), '${stats?.averageAccuracy ?? 0}%'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Menu Items
                _buildMenuItem(Icons.language, context.l10n('language'), onTap: () {
                  final localeProvider = context.read<LocaleProvider>();
                  if (localeProvider.isUrdu) {
                    localeProvider.setLocale(const Locale('en'));
                  } else {
                    localeProvider.setLocale(const Locale('ur'));
                  }
                }, trailing: Text(context.read<LocaleProvider>().isUrdu ? 'اردو' : 'English')),
                _buildMenuItem(Icons.history, 'Practice History', onTap: () {}),
                _buildMenuItem(Icons.bookmark_outline, 'Bookmarked Questions', onTap: () {}),
                _buildMenuItem(Icons.notifications_none, 'Notifications', onTap: () {}),
                _buildMenuItem(Icons.help_outline, 'Help & Support', onTap: () {}),
                _buildMenuItem(
                  Icons.logout, 
                  context.l10n('logout'), 
                  isDestructive: true,
                  onTap: () async {
                    await userProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.primaryCrimson : AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.primaryCrimson : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
