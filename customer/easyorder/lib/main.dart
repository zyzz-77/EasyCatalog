import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easyorder/firebase_options.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/data_service.dart';
import 'package:easyorder/utils/auth_service.dart';
import 'package:easyorder/utils/order_service.dart';
import 'package:easyorder/screens/login_screen.dart';
import 'package:easyorder/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DataService().init();
  await AuthService().ensureLoaded();
  await OrderService().ensureLoaded();
  runApp(const EasyOrderApp());
}

class EasyOrderApp extends StatelessWidget {
  const EasyOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'EasyOrder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: user != null ? const MainScreen() : const LoginScreen(),
    );
  }
}
