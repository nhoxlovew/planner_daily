import 'package:flutter/material.dart';
import 'package:planner_daily/screen/login.dart';
import 'package:planner_daily/screen/statistic.dart'; // Import the TaskStatisticsScreen
import 'package:planner_daily/theme/theme_provider.dart'; // Import your ThemeProvider
import 'package:provider/provider.dart'; // Import Provider

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Cài đặt',
          style: TextStyle(
              color: Colors.white, fontSize: 20), // Fixed font size for AppBar
        ),
        backgroundColor: Color(0xFF57015A), // Match your app's color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thống kê công việc', themeProvider),
            _buildStatisticCard(themeProvider),
            _buildDivider(),
            _buildSectionTitle('Chủ đề', themeProvider),
            _buildThemeDropdown(themeProvider),
            _buildDivider(),
            _buildSectionTitle('Tùy chỉnh giao diện', themeProvider),
            _buildTextColorDropdown(themeProvider),
            _buildFontSizeSlider(themeProvider),
            _buildDivider(),
            _buildLogoutButton(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: themeProvider.fontSize, // Use dynamic font size
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatisticCard(ThemeProvider themeProvider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: ListTile(
        title: Text(
          'Xem thống kê công việc',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: themeProvider.fontSize, // Use dynamic font size
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskStatisticsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildThemeDropdown(ThemeProvider themeProvider) {
    return DropdownButton<String>(
      value: themeProvider.isDarkMode
          ? 'Tối'
          : 'Sáng', // Updated to use 'Tối' and 'Sáng'
      icon: Icon(Icons.arrow_drop_down, color: themeProvider.textColor),
      onChanged: (String? newValue) {
        setState(() {
          themeProvider.toggleTheme(); // Toggle the theme
        });
      },
      items: <String>['Sáng', 'Tối'] // Updated dropdown items
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: themeProvider.textColor)),
        );
      }).toList(),
    );
  }

  Widget _buildTextColorDropdown(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Màu chữ',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: themeProvider.fontSize, // Use dynamic font size
          ),
        ),
        DropdownButton<Color>(
          value: themeProvider.textColor,
          icon: Icon(Icons.arrow_drop_down, color: themeProvider.textColor),
          onChanged: (Color? newColor) {
            if (newColor != null) {
              themeProvider.setTextColor(newColor);
            }
          },
          items: <Color>[
            Colors.black,
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.orange
          ].map<DropdownMenuItem<Color>>((Color color) {
            return DropdownMenuItem<Color>(
              value: color,
              child: Container(
                height: 20,
                width: 20,
                color: color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kích thước chữ',
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: themeProvider.fontSize, // Use dynamic font size
          ),
        ),
        Slider(
          value: themeProvider.fontSize,
          min: 12.0,
          max: 24.0,
          divisions: 12,
          label: themeProvider.fontSize.round().toString(),
          onChanged: (double newSize) {
            themeProvider.setFontSize(newSize);
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], thickness: 1);
  }

  Widget _buildLogoutButton(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final confirmLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Xác nhận đăng xuất',
                        style: TextStyle(color: themeProvider.textColor)),
                    content: Text('Bạn có chắc chắn muốn đăng xuất không?',
                        style: TextStyle(color: themeProvider.textColor)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false), // No
                        child: Text('Hủy',
                            style: TextStyle(color: themeProvider.textColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true), // Yes
                        child: Text('Đăng xuất',
                            style: TextStyle(color: themeProvider.textColor)),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              }
            },
            child: Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF57015A),
              padding: EdgeInsets.symmetric(vertical: 15),
              textStyle: TextStyle(fontSize: 16), // Button text size
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
