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
        SnackBar(
            content: Text('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu')),
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
        title: Text(
          'Đăng nhập',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF57015A),
      ),
      body: SingleChildScrollView(
        // Add this line
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adjusted the height of the image
            SizedBox(
              height: 350, // Set the height of the image
              child: Image.asset(
                "assets/img/login.png",
                fit: BoxFit
                    .contain, // Adjusts the image to contain within the box
              ),
            ),
            SizedBox(height: 20), // Space between the image and the fields
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  labelText: 'Tên tài khoản',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10), // Space between username and password fields
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  labelStyle: TextStyle(color: Colors.white)),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 20), // Space between the fields and the button
            SizedBox(
              width: double.infinity, // Make the button take full width
              child: ElevatedButton(
                onPressed: _login, // Call _login directly
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 2, 1, 90), // Set button background color
                  padding: EdgeInsets.symmetric(
                      vertical: 13.0), // Increase padding for better touch area
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Rounded corners for modern look
                  ),
                ),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 18, // Adjust the text size
                    fontWeight: FontWeight.bold, // Bold text for emphasis
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
