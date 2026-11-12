// auth_flow/authscreen.dart
// ignore_for_file: unused_import, override_on_non_overriding_member

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loginscreen.dart';
import 'signUpScreen.dart';

// The main entry point for the authentication flow
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthHomeScreen();
  }
}

// =========================
// 1. Initial Auth Home Page (Splash/Welcome Screen)
// =========================
class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 40, 80, 242), // Blue
              Color.fromARGB(255, 182, 83, 232) // Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Illustration (assuming the asset path is correct)
                Image.asset(
                  'assets/download (2)-Photoroom.png',
                  height: 300,
                  // Ensure the image fits within the bounds on smaller screens
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                // App Title
                Text(
                  'Bytly',
                  style: TextStyle(
                    fontFamily: GoogleFonts.caveat().fontFamily,
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // =========================
                // LOGIN BUTTON - Navigates to LoginFormScreen (in external file)
                // =========================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 249, 7),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      // NAVIGATING TO EXTERNAL LOGIN SCREEN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // =========================
                // REGISTER BUTTON - Navigates to RegisterFormScreen (in external file)
                // =========================
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterFormScreen {
  const RegisterFormScreen();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}



