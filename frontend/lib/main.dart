import 'package:flutter/material.dart';
import 'package:frontend/widget_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consume Wise',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: WidgetTree(), // Start with Splash Screen
    );
  }
}
