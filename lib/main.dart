// main.dart
import 'package:flutter/material.dart';
import 'homepage.dart'; // IMPORTANT: Replace 'your_app_name' with your actual project name!

void main() {
  runApp(const MyApp());
}

// MyApp is the root of your Flutter application.
// It must extend StatelessWidget or StatefulWidget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,// MaterialApp provides basic Material Design setup
      title: 'PHIL App', // A title for your app
      theme: ThemeData( // Define your app's theme
        primarySwatch: Colors.blue, // Example primary color
      ),
      home: const MyHomePage(), // This now points to the MyHomePage from homepage.dart
    );
  }
}