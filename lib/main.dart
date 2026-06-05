import 'package:flutter/material.dart';
import 'package:easycatalog/utils/app_theme.dart';
import 'package:easycatalog/screens/splash_screen.dart';

void main() {
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
