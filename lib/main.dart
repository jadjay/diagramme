import 'package:flutter/material.dart';

void main() {
  runApp(const DiagrammeApp());
}

class DiagrammeApp extends StatelessWidget {
  const DiagrammeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: Colors.white,
      ),
    );
  }
}
