import 'package:flutter/material.dart';
import 'package:fyp_retail/app_router.dart';

import '../app_router.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text("Settings", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: Colors.green),
                  title: Text("Profile"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.green),
                  title: Text("Notifications"),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.lock, color: Colors.green),
                  title: Text("Privacy & Security"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.green),
                  title: Text("Help & Support"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // POS Button
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.pos);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("POS", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

