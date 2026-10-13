import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/character_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'views/auth/login_screen.dart';
import 'views/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CandyAiApp());
}

class CandyAiApp extends StatelessWidget {
  const CandyAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: MaterialApp(
        title: 'Candy.ai',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Consumer<AuthViewModel>(
          builder: (context, authVm, _) {
            if (!authVm.isLoggedIn) {
              return const LoginScreen();
            }
            return const HomeShell();
          },
        ),
      ),
    );
  }
}
