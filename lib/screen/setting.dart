import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Default value for notifications
  String _theme = 'Light'; // Default theme

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ListTile(
              title: Text('Change Email'),
              onTap: () {
                // Handle email change logic
              },
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                // Handle password change logic
              },
            ),
            Divider(),

            // Notifications Setting
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(),

            // Theme Setting
            Text(
              'App Theme',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            DropdownButton<String>(
              value: _theme,
              icon: Icon(Icons.arrow_downward),
              onChanged: (String? newValue) {
                setState(() {
                  _theme = newValue!;
                });
              },
              items: <String>['Light', 'Dark', 'System Default']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Divider(),

// Log Out Button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle log out logic
              },
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blueAccent, // Use backgroundColor instead of primary
              ),
            ),
          ],
        ),
      ),
    );
  }
}
