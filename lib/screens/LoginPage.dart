import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:vrrealstatedemo/screens/DevicesPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _obscureText = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecialCharacter =
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigit) {
      return 'Password must contain at least one digit';
    }
    if (!hasSpecialCharacter) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      _showSnackBar('Login successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DevicesPage()),
      );

      final email = _emailController.text;
      final password = _passwordController.text;

      // Check network connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _showSnackBar(
            'No internet connection. Please check your network settings.');
        return;
      }

      // try {
      //   final response = await http
      //       .post(
      //         Uri.parse(dotenv.env['API_URL']!),
      //         headers: <String, String>{
      //           'Content-Type': 'application/json; charset=UTF-8',
      //         },
      //         body: jsonEncode(<String, String>{
      //           'email': email,
      //           'password': password,
      //         }),
      //       )
      //       .timeout(const Duration(seconds: 60)); // Set timeout duration

      //   if (response.statusCode == 200) {
      //     // Store credentials securely
      //     await _secureStorage.write(key: 'email', value: email);
      //     await _secureStorage.write(key: 'password', value: password);

      //     _showSnackBar('Login successful');
      //     Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(builder: (context) => const DevicesPage()),
      //     );
      //   } else if (response.statusCode == 401) {
      //     _showSnackBar('Unauthorized. Please check your credentials.');
      //   } else if (response.statusCode == 500) {
      //     _showSnackBar('Server error. Please try again later.');
      //   } else {
      //     _showSnackBar('An error occurred. Please try again.');
      //   }
      // } on http.ClientException {
      //   _showSnackBar('Network error. Please try again.');
      // } on TimeoutException {
      //   _showSnackBar('Request timed out. Please try again.');
      // } catch (e) {
      //   _showSnackBar('An error occurred. Please try again.');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final size = mediaQuery.size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: size.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: size.height * 0.05),
                        Icon(
                          Icons.vrpano_outlined,
                          size: size.width * 0.25,
                          color: theme.colorScheme.onPrimary,
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          'Welcome to VR Real Estate',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.05),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          validator: _validateEmail,
                          icon: Icons.email,
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          validator: _validatePassword,
                          icon: Icons.lock,
                          obscureText: _obscureText,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.secondary,
                            padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _handleSignIn,
                          child: Text(
                            'Login',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Handle forgot password logic
                              },
                              child: Text(
                                'Forgot Password?',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle signup logic
                              },
                              child: Text(
                                'Sign Up',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
          prefixIcon:
              Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: validator,
      ),
    );
  }
}
