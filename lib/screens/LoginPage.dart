import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

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

      // final email = _emailController.text;
      // final password = _passwordController.text;

      // Check network connectivity
      //   var connectivityResult = await Connectivity().checkConnectivity();
      //   if (connectivityResult == ConnectivityResult.none) {
      //     _showSnackBar(
      //         'No internet connection. Please check your network settings.');
      //     return;
      //   }

      //   try {
      //     final response = await http
      //         .post(
      //           Uri.parse(dotenv.env['API_URL']!),
      //           headers: <String, String>{
      //             'Content-Type': 'application/json; charset=UTF-8',
      //           },
      //           body: jsonEncode(<String, String>{
      //             'email': email,
      //             'password': password,
      //           }),
      //         )
      //         .timeout(const Duration(seconds: 60)); // Set timeout duration

      //     if (response.statusCode == 200) {
      //       // Store credentials securely
      //       await _secureStorage.write(key: 'email', value: email);
      //       await _secureStorage.write(key: 'password', value: password);

      //       _showSnackBar('Login successful');
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const DevicesPage()),
      //       );
      //     } else if (response.statusCode == 401) {
      //       _showSnackBar('Unauthorized. Please check your credentials.');
      //     } else if (response.statusCode == 500) {
      //       _showSnackBar('Server error. Please try again later.');
      //     } else {
      //       _showSnackBar('An error occurred. Please try again.');
      //     }
      //   } on http.ClientException {
      //     _showSnackBar('Network error. Please try again.');
      //   } on TimeoutException {
      //     _showSnackBar('Request timed out. Please try again.');
      //   } catch (e) {
      //     _showSnackBar('An error occurred. Please try again.');
      //   }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        double padding = constraints.maxWidth * 0.1;
        double fontSize = constraints.maxWidth * 0.05;
        double iconSize = constraints.maxWidth * 0.18;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.vrpano_outlined,
                  size: iconSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Welcome! to VR Real Estate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: fontSize / 2,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: Size(constraints.maxWidth / 6, 50.0),
                  ),
                  onPressed: _handleSignIn,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Handle forgot password logic
                      },
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle signup logic
                      },
                      child: const Text('Signup'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
