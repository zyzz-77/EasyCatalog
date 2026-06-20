import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easycatalog/firebase_options.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EasyCatalogApp());
}

class EasyCatalogApp extends StatelessWidget {
  const EasyCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyCatalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
