import 'package:flutter/material.dart';
import 'package:easycatalog/utils/auth_service.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/screens/login_screen.dart';
import 'package:easycatalog/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.loadTokens();
  runApp(EasyCatalogApp(isLoggedIn: auth.isLoggedIn));
}

class EasyCatalogApp extends StatelessWidget {
  final bool isLoggedIn;

  const EasyCatalogApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyCatalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
