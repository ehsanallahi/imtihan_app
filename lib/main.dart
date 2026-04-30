import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImtihanApp());
}

class ImtihanApp extends StatelessWidget {
  const ImtihanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imtihan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
