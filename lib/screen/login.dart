import 'package:flutter/material.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/data/model/user.dart'; // Ensure you have your DBHelper for login
import 'package:planner_daily/mainscreen.dart'; // Import your MainScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Hardcoded test credentials
  final String _testUsername = 'testuser@gmail.com';
  final String _testPassword = 'password123';

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Validate the input
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu')),
      );
      return; // Exit the method if validation fails
    }

    // Check against test credentials first
    if (username == _testUsername && password == _testPassword) {
      // Navigate to MainScreen if test login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Use DBHelper to check for valid user
      User? user = await DBHelper().loginUser(username, password);

      if (user != null) {
        // Navigate to MainScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // Handle login error (e.g., show an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Đăng nhập thất bại! Hãy kiểm tra lại tài khoản hoặc mật khẩu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 212, 157, 216), // Light background color for better contrast
      appBar: AppBar(
        title: const Text('Đăng nhập',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF57015A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Image.asset(
                  "assets/img/login.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30), // Increased space below the image
              const Text(
                'Chào mừng bạn đến với DailyPlanner!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 100, 0, 0),
                ),
              ),
              const SizedBox(
                  height: 20), // Space between the greeting and text fields
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Tên tài khoản',
                  labelStyle: const TextStyle(color: Color(0xFF57015A)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF57015A)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(
                  height:
                      15), // Increased space between username and password fields
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  labelStyle: const TextStyle(color: Color(0xFF57015A)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF57015A)),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                obscureText: true,
              ),
              const SizedBox(height: 30), // Increased space before the button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF57015A),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0), // Increased padding for the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: 20), // Additional space after the button (optional)
            ],
          ),
        ),
      ),
    );
  }
}
