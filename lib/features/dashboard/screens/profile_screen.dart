import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/models/user_model.dart';
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
                _buildMenuItem(Icons.history, 'Practice History', onTap: () {
                  _showPracticeHistory(context, stats);
                }),
                _buildMenuItem(Icons.bookmark_outline, 'Bookmarked Questions', onTap: () {
                  _showComingSoon(context, 'Bookmarked Questions');
                }),
                _buildMenuItem(Icons.notifications_none, 'Notifications', onTap: () {
                  _showComingSoon(context, 'Notifications');
                }),
                _buildMenuItem(Icons.help_outline, 'Help & Support', onTap: () {
                  _showHelpSupport(context);
                }),
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

  void _showPracticeHistory(BuildContext context, UserStats? stats) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppColors.primaryTeal),
                const SizedBox(width: 12),
                Text(
                  'Practice History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildHistoryStat('Tests Taken', '${stats?.testsTaken ?? 0}', Icons.assignment_turned_in_outlined),
            const Divider(height: 24),
            _buildHistoryStat('Average Accuracy', '${stats?.averageAccuracy ?? 0}%', Icons.track_changes),
            const Divider(height: 24),
            _buildHistoryStat('Current Streak', '${stats?.currentStreak ?? 0} days', Icons.local_fire_department_outlined),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryTeal, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.primaryGold),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Text(
          '$feature will be available in a future update. Stay tuned!',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryTeal),
            SizedBox(width: 12),
            Text('Help & Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Reach out to us:', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 18, color: AppColors.primaryTeal),
                SizedBox(width: 8),
                Text('support@imtihan.app'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.web_outlined, size: 18, color: AppColors.primaryTeal),
                SizedBox(width: 8),
                Text('www.imtihan.app'),
              ],
            ),
            SizedBox(height: 16),
            Text('App Version: 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

