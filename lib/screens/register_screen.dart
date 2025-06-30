import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import '/theme/theme_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);
    final registerUrl = Uri.parse('http://localhost:3000/api/user/register');

    final registerResponse = await http.post(
      registerUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': _userIdController.text.trim(),
        'password': _passwordController.text.trim(),
      }),
    );

    if (registerResponse.statusCode == 201) {
      // Registration successful, now perform login
      final loginUrl = Uri.parse('http://localhost:3000/api/user/login');
      final loginResponse = await http.post(
        loginUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userIdController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      setState(() => _isLoading = false);

      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        final token = loginData['data']['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        final loginError = jsonDecode(loginResponse.body)['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginError), duration: Duration(seconds: 2)),
        );
      }
    } else {
      setState(() => _isLoading = false);
      final error =
          jsonDecode(registerResponse.body)['message'] ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ready to get organised?',
                style: TextStyle(
                  color: ThemeColors.textPrimary,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _userIdController,
                style: TextStyle(color: ThemeColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Username',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ThemeColors.textPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: ThemeColors.textPrimary),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ThemeColors.textPrimary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator(color: ThemeColors.accent)
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.accent,
                    ),
                    onPressed: () async {
                      await _registerUser();
                    },
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeColors.textPrimary,
                      ),
                    ),
                  ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: ThemeColors.textPrimary),
                    text: 'Already have an account? ',
                    children: [
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: ThemeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
