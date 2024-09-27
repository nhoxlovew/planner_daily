import 'package:flutter/material.dart';
import 'screen/welcome.dart'; // Import your WelcomeScreen
import 'screen/login.dart'; // Import your LoginScreen if needed

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(), // Set WelcomeScreen as the home screen
      routes: {
        // Define routes for navigation
        '/login': (context) => LoginScreen(),
        // Add other routes as necessary
      },
    );
  }
}
