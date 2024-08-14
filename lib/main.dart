import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:vrrealstatedemo/screens/device_page.dart';
import 'package:vrrealstatedemo/screens/login_page.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
          surface: const Color(0xFFFFFFFF), // Surface color
          error: Colors.red, // Error color
          onPrimary: Colors.white, // Text color on primary
          onSecondary: Colors.green, // Text color on secondary
          onSurface: Colors.black, // Text color on surface
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
      home: const Init(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/devices': (context) => const DevicesPage(),
      },
    );
  }
}

class Init extends StatelessWidget {
  const Init({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: const FlutterSecureStorage().read(key: 'auth_token'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          FlutterNativeSplash.remove();
          if (snapshot.data != null) {
            return const DevicesPage();
          } else {
            return const LoginPage();
          }
        }
        return Center(
          child: StyledCircularProgressIndicator(
            size: 80.0,
            strokeWidth: 8.0,
            backgroundColor: Colors.grey,
            valueColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      },
    );
  }
}
