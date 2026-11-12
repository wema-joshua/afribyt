// auth_flow/loginscreen.dart
// ignore_for_file: unused_import

import 'dart:ui';
import 'package:flutter/material.dart';

import '../tabs/homepage.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

// --- Color Palette ---
const Color _kCyan = Color(0xFF00E5FF);
const Color _kDeepBlue = Color(0xFF1A0A6B);
const Color _kPurple = Color(0xFF6A0DAD);
const Color _kGlassWhite = Color(0x1AFFFFFF);
const Color _kSoftWhite = Color(0xFFFFFFFF);
const Color _kFieldBg = Color(0x26FFFFFF);

// ======================================================
// GRADIENT BUTTON
// ======================================================
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C6FF),
            Color(0xFF8A2BE2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: _kSoftWhite,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// GLASS TEXTFIELD
// ======================================================
class GlassTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;
  final IconData prefixIcon;

  const GlassTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _kCyan, width: 1.8),
        color: _kFieldBg,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: _kSoftWhite,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: _kCyan,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

// ======================================================
// GLOW ORB
// ======================================================
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double left;
  final double top;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.left,
    required this.top,
    this.opacity = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// LOGIN SCREEN
// ======================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  // CONTROLLERS
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final rolecontroller =
      TextEditingController();

  String? _selectedRole;

  bool isLoading = false;

  // SERVICES
  final AuthRepository authRepository =
      AuthRepository();

  final AuthService authService =
      AuthService();

  // ======================================================
  // LOGIN FUNCTION
  // ======================================================
  Future<void> handleLogin() async {

    String email =
        emailController.text.trim();

    String password =
        passwordController.text.trim();

    String role =
        rolecontroller.text.trim();

    // VALIDATION
    if (email.isEmpty ||
        password.isEmpty ||
        role.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );

      return;
    }

    // EMAIL VALIDATION
    if (!email.contains('@')) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid email",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final result =
          await authRepository.login(
        email,
        password,
        role,
      );
      print(result);

      // SUCCESS
      if (result["success"] == true) {

        final data = result["data"];

        // SAVE TOKEN
        await authService.saveToken(
          data["token"],
        );

        if (!mounted) return;

        // NAVIGATE
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AfribytApp(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result["data"]["message"] ??
                  "Login failed",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ======================================================
  // DISPOSE
  // ======================================================
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    rolecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight =
        MediaQuery.of(context).size.height;

    final screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: double.infinity,

        child: Stack(
          children: [

            // BACKGROUND
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D0060),
                      Color(0xFF1A006B),
                      Color(0xFF3A0080),
                      Color(0xFF0A0050),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // GLOW EFFECTS
            _GlowOrb(
              size: 260,
              color: const Color(0xFF1565C0),
              left: -60,
              top: 60,
              opacity: 0.7,
            ),

            _GlowOrb(
              size: 200,
              color: const Color(0xFF7B1FA2),
              left: screenWidth * 0.55,
              top: -40,
              opacity: 0.65,
            ),

            // CONTENT
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: screenHeight * 0.08,
                ),

                child: Column(
                  children: [

                    // BACK BUTTON
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // GLASS CARD
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(24),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 18,
                          sigmaY: 18,
                        ),

                        child: Container(
                          width: double.infinity,

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 36,
                          ),

                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                              24,
                            ),

                            color:
                                const Color(0x22FFFFFF),

                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.25),
                            ),
                          ),

                          child: Column(
                            children: [

                              // TITLE
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Log in to Bytly',
                                style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(0.7),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // EMAIL
                              GlassTextField(
                                hintText: 'Email',
                                controller:
                                    emailController,
                                prefixIcon:
                                    Icons.email_outlined,
                              ),

                              // PASSWORD
                              GlassTextField(
                                hintText: 'Password',
                                controller:
                                    passwordController,
                                prefixIcon:
                                    Icons.lock_outline,
                                isPassword: true,
                              ),

                              // ROLE DROPDOWN
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),

                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),

                                  border: Border.all(
                                    color: _kCyan,
                                    width: 1.8,
                                  ),

                                  color: _kFieldBg,
                                ),

                                child:
                                    DropdownButtonHideUnderline(
                                  child:
                                      DropdownButton<String>(
                                    value: _selectedRole,

                                    isExpanded: true,

                                    dropdownColor:
                                        const Color(
                                      0xFF1A006B,
                                    ),

                                    iconEnabledColor:
                                        _kCyan,

                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),

                                    hint: Row(
                                      children: [
                                        const Icon(
                                          Icons.badge_outlined,
                                          color: _kCyan,
                                        ),

                                        const SizedBox(
                                            width: 12),

                                        Text(
                                          'Select Role',
                                          style: TextStyle(
                                            color: Colors
                                                .white
                                                .withOpacity(
                                                    0.5),
                                          ),
                                        ),
                                      ],
                                    ),

                                    items: [
                                      'technician',
                                      'customer',
                                    ]
                                        .map(
                                          (role) =>
                                              DropdownMenuItem(
                                            value: role,
                                            child: Text(
                                              role,
                                              style:
                                                  const TextStyle(
                                                color: Colors
                                                    .white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),

                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRole =
                                            value;

                                        rolecontroller
                                                .text =
                                            value ?? '';
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // LOGIN BUTTON
                              isLoading
                                  ? const CircularProgressIndicator(
                                      color:
                                          Colors.white,
                                    )
                                  : GradientButton(
                                      text: 'Log In',
                                      onPressed:
                                          handleLogin,
                                    ),

                              const SizedBox(height: 24),

                              // SIGNUP
                              Text.rich(
                                TextSpan(
                                  text:
                                      "Don't have an account? ",

                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(
                                      0.7,
                                    ),
                                  ),

                                  children: const [
                                    TextSpan(
                                      text: 'Sign up',
                                      style: TextStyle(
                                        color: _kCyan,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

// ======================================================
// EASY NAVIGATION
// ======================================================
Widget loginScreen() =>
    const LoginScreen();