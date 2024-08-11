import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vrrealstatedemo/screens/LoginPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VR Real Estate Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C2747), // Primary color
          primary: const Color(0xFF2C2747), // Primary color
          primaryContainer: const Color(0xFF998AE9), // Primary color accent
          secondary: const Color(0xFFE0FF63), // Accent color
          background: const Color(0xFFFFFFFF), // Base color
          surface: const Color(0xFFFFFFFF), // Surface color
          error: Colors.red, // Error color
          onPrimary: Colors.white, // Text color on primary
          onSecondary: Colors.green, // Text color on secondary
          onSurface: Colors.black, // Text color on surface
          onBackground: Colors.black, // Text color on background
        ),
        textTheme: const TextTheme(
          headlineMedium:
              TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
          bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
