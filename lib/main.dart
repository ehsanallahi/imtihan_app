import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/mcq/providers/mcq_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/past_papers/providers/past_paper_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => McqProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PastPaperProvider()),
      ],
      child: const ImtihanApp(),
    ),
  );
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
