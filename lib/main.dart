import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SchoolBusParentApp());
}

class SchoolBusParentApp extends StatelessWidget {
  const SchoolBusParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolBus Parents Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'sans-serif',
        primaryColor: const Color(0xFFD35400),
        scaffoldBackgroundColor: const Color(0xFF0F0F1B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD35400),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD35400),
          secondary: Color(0xFFFF7F24),
          background: Color(0xFF0F0F1B),
          surface: Color(0xFF16162E),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
