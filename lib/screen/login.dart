import 'package:flutter/material.dart';
import 'package:planner_daily/data/Dbhepler/db_helper.dart';
import 'package:planner_daily/data/model/user.dart'; // Ensure you have your DBHelper for login
import 'package:planner_daily/mainscreen.dart'; // Import your MainScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Hardcoded test credentials
  final String _testUsername = 'testuser';
  final String _testPassword = 'password123';

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Validate the input
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password.')),
      );
      return; // Exit the method if validation fails
    }

    // Check against test credentials first
    if (username == _testUsername && password == _testPassword) {
      // Navigate to MainScreen if test login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // Use DBHelper to check for valid user
      User? user = await DBHelper().loginUser(username, password);

      if (user != null) {
        // Navigate to MainScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        // Handle login error (e.g., show an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Đăng nhập thất bại! Hãy kiểm tra lại tài khoản hoặc mật khẩu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 67, 2, 70),
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF57015A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                "assets/img/login.png",
                fit: BoxFit.cover, // Adjusts the image to fill the space
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Tên tài khoản'),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
