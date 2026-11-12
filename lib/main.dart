// main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'auth_flow/onboardingScreen.dart';
import 'tabs/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AfribytSplashScreen(),
    );
  }
}

class AfribytSplashScreen extends StatefulWidget {
  const AfribytSplashScreen({super.key});

  @override
  State<AfribytSplashScreen> createState() =>
      _AfribytSplashScreenState();
}

class _AfribytSplashScreenState
    extends State<AfribytSplashScreen>
    with TickerProviderStateMixin {
  // ==============================
  // AUTH SERVICE
  // ==============================
  final AuthService authService =
      AuthService();

  late Animation<double> fadeAnimation;
  late AnimationController fadeController;
  late Animation<Offset> slideAnimation;
  // ==============================
  // ANIMATION CONTROLLERS
  // ==============================
  late AnimationController slideController;

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _initializeApp();
  }

  // ==============================
  // SETUP ANIMATIONS
  // ==============================
  void _setupAnimations() {

    // LOGO SLIDE ANIMATION
    slideController = AnimationController(
      duration: const Duration(
        milliseconds: 1900,
      ),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: slideController,
        curve: Curves.easeOutBack,
      ),
    );

    // TEXT FADE ANIMATION
    fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: Curves.easeIn,
      ),
    );
  }

  // ==============================
  // INITIALIZE APP
  // ==============================
  Future<void> _initializeApp() async {

    // RUN ANIMATIONS
    await Future.wait([
      slideController.forward(),
      fadeController.forward(),
    ]);

    // SMALL EXTRA DELAY
    await Future.delayed(
      const Duration(milliseconds: 1000),
    );

    // CHECK AUTH
    await _checkAuthToken();
  }

  // ==============================
  // CHECK JWT TOKEN
  // ==============================
  Future<void> _checkAuthToken() async {

    bool loggedIn =
        await authService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {

      // USER AUTHENTICATED
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AfribytApp(),
        ),
      );

    } else {

      // USER NOT AUTHENTICATED
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF005BEA),
              Color.fromARGB(
                255,
                135,
                62,
                253,
              ),
              Color.fromARGB(
                255,
                199,
                130,
                241,
              ),
            ],
            stops: [0.0, 0.75, 0.95],
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              // =====================
              // LOGO
              // =====================
              SlideTransition(
                position: slideAnimation,
                child: Image.asset(
                  'assets/8806258-Photoroom.png',
                  height: 225,
                  width: 225,
                ),
              ),

              const SizedBox(height: 20),

              // =====================
              // APP NAME
              // =====================
              FadeTransition(
                opacity: fadeAnimation,
                child: Text(
                  'Bytly',
                  style:
                      GoogleFonts.poppins(
                    textStyle:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight:
                          FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // =====================
              // LOADING INDICATOR
              // =====================
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}