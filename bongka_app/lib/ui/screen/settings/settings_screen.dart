import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/theme_provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: no notification backend/preferences store exists yet —
  // this is local-only UI state until one is wired up.
  bool _notificationsEnabled = true;

  Future<void> _handleSignOut(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text('Settings', style: TextStyles.headingStyle),
        const SizedBox(height: 20),

        // Profile card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.blueColor.withValues(alpha: 0.1),
                child: Text(
                  user != null && user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyles.bodyStyle.copyWith(
                    color: AppColors.blueColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest',
                      style: TextStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 2),
                      Text(user.email, style: TextStyles.smallStyle),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Preferences
        _SettingTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark mode',
          trailing: Switch(
            value: isDarkMode,
            activeColor: AppColors.blueColor,
            onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
          ),
        ),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.notifications_outlined,
          title: 'Notification',
          trailing: Switch(
            value: _notificationsEnabled,
            activeColor: AppColors.blueColor,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
        ),

        const SizedBox(height: 20),

        // Account
        _SettingTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _SettingTile(
          icon: Icons.star_outline,
          title: 'Rate Bongka',
          onTap: () {
            // TODO: wire up to the store listing once published
            // (needs the url_launcher package, not yet in pubspec.yaml).
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanks for the support! 🙌')),
            );
          },
        ),

        const SizedBox(height: 24),

        _SettingTile(
          icon: Icons.logout,
          title: 'Sign out',
          iconColor: AppColors.redColor,
          textColor: AppColors.redColor,
          onTap: () => _handleSignOut(context),
        ),
      ],
    );
  }
}

/// A single row in the Settings list: icon in a soft rounded square,
/// a title, and either a trailing widget (e.g. a Switch) or a chevron
/// if the row is tappable.
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.blueColor,
    this.textColor = AppColors.textColor,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.bodyStyle.copyWith(color: textColor),
                ),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                          size: 20,
                        )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
