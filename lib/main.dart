import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(const BrainTumorApp());
}

class BrainTumorApp extends StatelessWidget {
  const BrainTumorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Tumor Detection',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const LoginScreen(),
    );
  }
}
