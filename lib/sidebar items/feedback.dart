import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import the package

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // 1. State variables
  double _currentRating = 3.0;
  final TextEditingController _commentController = TextEditingController();

  // Dispose of the controller when the widget is removed
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 2. Submission logic
  void _submitFeedback() {
    final rating = _currentRating;
    final comment = _commentController.text.trim();

    // --- Replace this with your actual submission logic (e.g., API call, database write) ---
    print('Rating submitted: $rating stars');
    print('Comment submitted: "$comment"');

    // Show a confirmation to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF8A2BE2), // Purple for snackbar
      ),
    );

    // Optionally clear the fields after submission
    setState(() {
      _currentRating = 3.0; // Reset rating
      _commentController.clear(); // Clear comment text
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the theme colors explicitly for better control
    const Color primaryBlue = Color(0xFF007BFF); // A vibrant blue
    const Color primaryPurple = Color(0xFF8A2BE2); // A strong purple
    const Color lightGrey = Color(0xFFF0F2F5); // For background
    const Color darkText = Color(0xFF333333); // For text

    return Scaffold(
      backgroundColor: lightGrey, // Set a light background for the scaffold
      appBar: AppBar(
        title: const Text(
          'Customer Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        // Use a gradient for the AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight, // Fading towards the right
            ),
          ),
        ),
        elevation: 0, // No shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0), // Slightly increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Rating Section ---
            const Text(
              'How would you rate your experience?',
              style: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
                child: RatingBar.builder(
                  initialRating: _currentRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded, // Using rounded star icon
                    color: Colors.amber, // Classic gold for stars
                    size: 32.0,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _currentRating = rating;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 35.0),

            // --- Comment Section ---
            const Text(
              'Tell us more about your experience (Optional):',
              style: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 15.0),
            TextFormField(
              controller: _commentController,
              maxLines: 6, // Slightly more lines for comments
              decoration: InputDecoration(
                hintText: 'Enter your valuable comments here...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none, // No border by default
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                      color: primaryPurple,
                      width: 2.0), // Purple border on focus
                ),
                contentPadding: const EdgeInsets.all(20.0),
                alignLabelWithHint: true, // Hint text aligns at the top
              ),
              keyboardType: TextInputType.multiline,
              style: const TextStyle(color: darkText),
            ),
            const SizedBox(height: 50.0),

            // --- Submit Button ---
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, primaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0), // Rounded button
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // Make button background transparent to show gradient
                  shadowColor: Colors.transparent, // No shadow from ElevatedButton
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(
                      fontSize: 19.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}