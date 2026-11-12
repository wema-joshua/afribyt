import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Theme Colors (Consistent)
  static const Color primaryBlue = Color(0xFF007BFF);
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color lightGrey = Color(0xFFF0F2F5);
  static const Color darkText = Color(0xFF333333);
  static const double headerHeight = 150.0;

  // --- Helper Widget for the Custom Header ---
  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Back Button (positioned at the top-left)
          Positioned(
            top: 40, // Adjust this based on device status bar height
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ),
          // Title Text (centered towards the bottom of the header)
          const Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for Settings Items ---
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: primaryPurple),
        title: Text(
          title,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.w500),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: primaryBlue,
            ),
        onTap: onTap,
      ),
    );
  }

  // --- Helper Widget for Section Headers ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      // SafeArea ensures content doesn't overlap the status bar, especially important without an AppBar
      body: SafeArea(
        top: false, // We'll manage the top padding manually in the header
        child: Column(
          children: <Widget>[
            // 1. Custom Header (Replaces AppBar)
            _buildCustomHeader(context),

            // 2. Settings List Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // --- Account Settings ---
                    _buildSectionHeader('Account'),
                    _buildSettingsItem(
                      icon: Icons.lock_rounded,
                      title: 'Change Password',
                      onTap: () => print('Navigating to Change Password...'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.email_rounded,
                      title: 'Update Email',
                      onTap: () => print('Navigating to Update Email...'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.delete_forever_rounded,
                      title: 'Deactivate Account',
                      onTap: () => print('Showing Deactivation Dialog...'),
                    ),

                    // --- Application Settings ---
                    _buildSectionHeader('Application'),
                    // Switch Example
                    _buildSettingsItem(
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Mode',
                      onTap: () => print('Toggling Dark Mode...'),
                      trailing: Switch(
                        value: false, // Replace with actual state management variable
                        onChanged: (value) {
                          print('Dark Mode toggled: $value');
                          // setState/provider logic here
                        },
                        activeColor: primaryPurple,
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_rounded,
                      title: 'Notifications',
                      onTap: () => print('Navigating to Notification Settings...'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      onTap: () => print('Navigating to Language Selection...'),
                      trailing: const Text('English'),
                    ),

                    // --- Legal & About ---
                    _buildSectionHeader('Legal & Info'),
                    _buildSettingsItem(
                      icon: Icons.policy_rounded,
                      title: 'Privacy Policy',
                      onTap: () => print('Viewing Privacy Policy...'),
                    ),
                    _buildSettingsItem(
                      icon: Icons.gavel_rounded,
                      title: 'Terms of Service',
                      onTap: () => print('Viewing Terms of Service...'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}