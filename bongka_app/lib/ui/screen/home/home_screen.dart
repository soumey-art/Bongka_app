import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('BONGKA', style: TextStyles.headingStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textColor),
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.blueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppColors.blueColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user != null
                      ? 'Welcome, ${user.displayName}'
                      : 'Welcome to Bongka',
                  style: TextStyles.titleStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (user != null)
                  Text(user.email, style: TextStyles.smallStyle),
                const SizedBox(height: 24),
                if (user != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Cyber Safety Score: ${user.cyberSafetyScore}',
                      style: TextStyles.bodyStyle.copyWith(
                        color: AppColors.greenColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Text(
                  'This is a placeholder home screen — wire up your\nphishing simulator features here.',
                  textAlign: TextAlign.center,
                  style: TextStyles.smallStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


