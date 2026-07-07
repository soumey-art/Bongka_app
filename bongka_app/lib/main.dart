import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'ui/screen/auth/login_screen.dart';
import 'provider/auth_provider.dart';
import 'provider/scan_provider.dart';
import 'provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
=======

import 'theme/app_theme.dart';
import 'ui/screen/auth/login_screen.dart';

void main() {
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Bongkar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          );
        },
      ),
=======
    return MaterialApp(
      title: 'Bongka',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
>>>>>>> 155565cc5fe36546ef9c6118ccee665d19a5ba0f
    );
  }
}
