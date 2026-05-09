import 'package:flutter/material.dart';
import 'package:easyorder/utils/auth_service.dart';
import 'package:easyorder/utils/app_theme.dart';
import 'package:easyorder/utils/data_service.dart';
import 'package:easyorder/screens/login_screen.dart';
import 'package:easyorder/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  final data = DataService();
  await auth.loadSession();
  await data.init(); // baca URL param atau SharedPreferences
  runApp(EasyOrderApp(isLoggedIn: auth.isLoggedIn, hasResto: data.hasData));
}

class EasyOrderApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool hasResto;

  const EasyOrderApp({
    super.key,
    required this.isLoggedIn,
    required this.hasResto,
  });

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (isLoggedIn) {
      home = const MainScreen();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'EasyOrder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: home,
    );
  }
}
