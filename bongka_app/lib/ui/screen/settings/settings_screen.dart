import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
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

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Settings',
          style: TextStyles.headingStyle.copyWith(color: AppColors.textColor),
        ),
        const SizedBox(height: 20),

        // Profile card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
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
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyles.smallStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
    this.onTap,
    this.iconColor = AppColors.blueColor,
    this.textColor = AppColors.textColor,
  }) : trailing = null;

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceColor,
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
                      ? Icon(
                          Icons.chevron_right,
                          color: AppColors.textMuted,
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
