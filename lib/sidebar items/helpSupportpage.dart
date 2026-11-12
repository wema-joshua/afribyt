import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  // Theme Colors (Consistent with the Feedback Screen)
  static const Color primaryBlue = Color(0xFF007BFF); // Vibrant blue
  static const Color primaryPurple = Color(0xFF8A2BE2); // Strong purple
  static const Color lightGrey = Color(0xFFF0F2F5); // Light background
  static const Color darkText = Color(0xFF333333); // Main text color

  // Sample FAQ Data
  final List<Map<String, String>> faqData = const [
    {
      'question': 'How do I reset my password?',
      'answer': 'You can reset your password by going to the Profile screen, selecting "Settings", and choosing the "Change Password" option.',
    },
    {
      'question': 'What devices are supported?',
      'answer': 'Our application supports Android devices running OS 8.0 and above, and iOS devices running iOS 14 or later.',
    },
    {
      'question': 'How can I submit a bug report?',
      'answer': 'Please navigate to the Feedback screen in the main menu to submit a detailed bug report, or use the "Contact Us" link below.',
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, we use industry-standard encryption protocols (SSL/TLS) to ensure all your personal data and transaction information is protected.',
    },
  ];

  // Helper widget to build the individual FAQ item
  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Theme(
          // Ensures the ExpansionTile's background color is correct
          data: ThemeData(
            dividerColor: Colors.transparent, 
            splashColor: primaryBlue.withOpacity(0.1),
          ),
          child: ExpansionTile(
            key: PageStorageKey(question), // Required for ExpansionTile in a list
            iconColor: primaryPurple,
            collapsedIconColor: primaryBlue,
            title: Text(
              question,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: darkText,
                fontSize: 16,
              ),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 15.0, top: 0.0),
                child: Text(
                  answer,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for a styled action button (e.g., call/email)
  Widget _buildActionButton(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryPurple, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        // Use a gradient for the AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Contact Header ---
            const Text(
              'Need immediate assistance?',
              style: TextStyle(
                  fontSize: 22.0, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 15.0),

            // --- Contact Action Grid ---
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                _buildActionButton(Icons.email_rounded, 'Email Us', () {
                  // TODO: Implement email intent (e.g., using url_launcher package)
                  print('Opening Email App...');
                }),
                _buildActionButton(Icons.phone_rounded, 'Call Us', () {
                  // TODO: Implement phone call intent
                  print('Opening Phone Dialer...');
                }),
                _buildActionButton(Icons.chat_bubble_rounded, 'Live Chat', () {
                  // TODO: Navigate to a Live Chat screen or web view
                  print('Navigating to Live Chat...');
                }),
                _buildActionButton(Icons.list_alt_rounded, 'Submit Ticket', () {
                  // TODO: Navigate to a dedicated support ticket form
                  print('Navigating to Submit Ticket Form...');
                }),
              ],
            ),

            const Divider(height: 50, thickness: 1, color: Colors.grey),

            // --- FAQ Header ---
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                  fontSize: 22.0, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 15.0),

            // --- FAQ List ---
            ...faqData.map((faq) => _buildFaqItem(faq['question']!, faq['answer']!)).toList(),
            
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}