import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '/screens/login_screen.dart';
import '/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  bool isTokenValid = false;
  if (token != null && !Jwt.isExpired(token)) {
    isTokenValid = true;
  }

  runApp(MainApp(isLoggedIn: isTokenValid));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
