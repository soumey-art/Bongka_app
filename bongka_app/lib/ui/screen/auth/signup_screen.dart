import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
import '../../screen/auth/login_screen.dart';
import '../../../provider/auth_provider.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );

      if (!context.mounted) return;
      // No more PIN setup step — a new account goes straight to Home
      // once Firebase Authentication + the Firestore profile are created.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: ${e.toString()}')));
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyles.smallStyle.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceColor,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.blueColor),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.surfaceBorder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo + Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          color: AppColors.blueDark,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'BONGKA',
                        style: TextStyles.titleStyle.copyWith(
                          color: AppColors.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ethical Hacking & Phishing Simulator',
                        style: TextStyles.smallStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Username
                Text(
                  'Username',
                  style: TextStyles.bodyStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyles.bodyStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                  decoration: _fieldDecoration('Enter your name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email
                Text(
                  'Email',
                  style: TextStyles.bodyStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyles.bodyStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                  decoration: _fieldDecoration('user@gmail.com'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                Text(
                  'Password',
                  style: TextStyles.bodyStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyles.bodyStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                  decoration: _fieldDecoration(
                    'Enter your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: AppColors.blueDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.blueDark,
                              ),
                            ),
                          )
                        : Text(
                            'SIGN UP',
                            style: TextStyles.buttonStyle.copyWith(
                              color: AppColors.blueDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // Already have account
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Already have Account?',
                      style: TextStyles.smallStyle.copyWith(
                        color: AppColors.blueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
