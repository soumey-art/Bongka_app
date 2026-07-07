import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'package:pract_app/theme/app_color.dart';
import 'package:pract_app/theme/app_textStyle.dart';
import 'package:pract_app/provider/auth_provider.dart';
=======
import '../../../theme/app_color.dart';
import '../../../theme/app_textStyle.dart';
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
<<<<<<< HEAD
  bool _isSubmitting = false;
=======
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await context.read<AuthProvider>().signIn(email, password);
      final user = context.read<AuthProvider>().currentUser;
      debugPrint('LOGIN SUCCESS -> uid: ${user?.id}, email: ${user?.email}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logged in as ${user?.email}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
=======
  void _handleLogin() {
    // TODO: hook up your authentication logic here
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo + Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
<<<<<<< HEAD
                        color: AppColors.blueColor.withValues(alpha: 0.1),
=======
                        color: AppColors.blueColor.withOpacity(0.1),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
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
                      'BONGKA',
                      style: TextStyles.titleStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ethical Hacking & Phishing Simulator',
                      style: TextStyles.smallStyle,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Email label + field
              Text('Email', style: TextStyles.bodyStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyles.bodyStyle.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'user@gmail.com',
                  hintStyle: TextStyles.smallStyle,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.blueColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Password label + field
              Text('Password', style: TextStyles.bodyStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyles.bodyStyle.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyles.smallStyle,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.blueColor),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    // TODO: navigate to forgot password flow
                  },
                  child: Text(
                    'Forget password?',
                    style: TextStyles.smallStyle.copyWith(
                      color: AppColors.blueColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
<<<<<<< HEAD
                  onPressed: _isSubmitting ? null : _handleLogin,
=======
                  onPressed: _handleLogin,
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
<<<<<<< HEAD
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'LOGIN',
                          style: TextStyles.buttonStyle.copyWith(
                            letterSpacing: 0.5,
                          ),
                        ),
=======
                  child: Text(
                    'LOGIN',
                    style: TextStyles.buttonStyle.copyWith(letterSpacing: 0.5),
                  ),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
