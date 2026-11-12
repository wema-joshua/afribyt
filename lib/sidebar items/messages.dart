import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  // Theme Colors (Consistent)
  static const Color primaryBlue = Color(0xFF007BFF);
  static const Color primaryPurple = Color(0xFF8A2BE2);
  static const Color lightGrey = Color(0xFFF0F2F5);
  static const Color darkText = Color(0xFF333333);

  // Sample Admin Messages
  final List<Map<String, String>> messages = const [
    {
      'subject': 'Important Security Update',
      'body': 'We have successfully rolled out a major security patch to enhance data protection and privacy across all user accounts. No action is required from your side.',
      'date': '2 hours ago',
    },
    {
      'subject': 'Service Downtime Notification',
      'body': 'Scheduled maintenance is planned for tomorrow, 11 PM to 1 AM EST. The app will be temporarily unavailable. We apologize for any inconvenience.',
      'date': 'Yesterday',
    },
    {
      'subject': 'New Feature: Custom Dashboards!',
      'body': 'Exciting news! You can now customize your main dashboard layout by dragging and dropping widgets. Check out the "New Features" section in the Help menu for a guide.',
      'date': '2 days ago',
    },
    {
      'subject': 'Welcome to the Platform!',
      'body': 'Thank you for joining our community. We are here to support your goals. Feel free to explore the Help & Support section if you have any questions.',
      'date': '1 week ago',
    },
  ];

  // Helper Widget for an individual Message Tile
  Widget _buildMessageTile(
      String subject, String body, String date, BuildContext context) {
    // Determine if the message is "new" (e.g., posted today)
    final bool isNew = date.contains('hour') || date.contains('minute');

    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // Typically navigates to a detailed view of the message
          print('Tapped message: $subject');
          _showDetailsModal(context, subject, body);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Admin/Person Icon (Styled)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [primaryPurple, primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded, // The requested person icon
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15.0),

              // Message Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Subject and Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                              fontSize: 16,
                              color: isNew ? primaryPurple : darkText,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: isNew ? primaryBlue : Colors.grey[600],
                            fontWeight: isNew ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),

                    // Snippet of the Body
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Modal to Show Full Message Details ---
  void _showDetailsModal(BuildContext context, String subject, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Header/Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                
                // Subject
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
                const Divider(height: 30, thickness: 1),

                // Body
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 30),

                // Close Button
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text(
          'Admin Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        // Gradient AppBar
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
      body: messages.isEmpty
          ? Center(
              child: Text(
                'No messages from the admin yet.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageTile(
                  message['subject']!,
                  message['body']!,
                  message['date']!,
                  context,
                );
              },
            ),
    );
  }
}