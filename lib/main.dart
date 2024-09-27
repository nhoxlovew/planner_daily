import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planner_daily/theme/theme_provider.dart'; // Import your ThemeProvider
import 'screen/welcome.dart'; // Import your WelcomeScreen
import 'screen/login.dart'; // Import your LoginScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Planner',
      theme: themeProvider.themeData, // Use the theme from ThemeProvider
      home: WelcomeScreen(), // Set WelcomeScreen as the home screen
      routes: {
        '/login': (context) => LoginScreen(),
        // Add other routes as necessary
      },
    );
  }
}
