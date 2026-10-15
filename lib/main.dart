import 'package:flutter/material.dart';
import 'package:cat_app/config.dart';
import 'package:cat_app/screens/home_shell.dart';
import 'package:cat_app/screens/onboarding_screen.dart';
import 'package:cat_app/state/app_state.dart';
import 'package:cat_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lê do aparelho o usuário salvo (se já passou pelo onboarding).
  await AppState.instance.init();
  runApp(const MiaudexApp());
}

class MiaudexApp extends StatelessWidget {
  const MiaudexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Sem usuário -> onboarding. Com usuário -> app com as 5 abas.
      home: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          return AppState.instance.isLoggedIn
              ? const HomeShell()
              : const OnboardingScreen();
        },
      ),
    );
  }
}
