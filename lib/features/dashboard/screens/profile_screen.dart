import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/screens/welcome_screen.dart';

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
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile Header
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.lightTeal,
                  child: Icon(Icons.person, size: 50, color: AppColors.primaryTeal),
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
                      _buildStatCard('Tests Taken', '${stats?.testsTaken ?? 0}'),
                      const SizedBox(width: 16),
                      _buildStatCard('Accuracy', '${stats?.averageAccuracy ?? 0}%'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Menu Items
                _buildMenuItem(Icons.history, 'Practice History', onTap: () {}),
                _buildMenuItem(Icons.bookmark_outline, 'Bookmarked Questions', onTap: () {}),
                _buildMenuItem(Icons.notifications_none, 'Notifications', onTap: () {}),
                _buildMenuItem(Icons.help_outline, 'Help & Support', onTap: () {}),
                _buildMenuItem(
                  Icons.logout, 
                  'Logout', 
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

  Widget _buildMenuItem(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap}) {
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
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
