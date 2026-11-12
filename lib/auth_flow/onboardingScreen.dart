// auth_flow/onboardingScreen.dart
import 'package:flutter/material.dart';
import 'authscreen.dart';

/// Bytly brand colors used across the onboarding flow.
class _BytlyColors {
  static const Color primary = Color.fromARGB(255, 36, 69, 253);
  static const Color primaryLight = Colors.white70;
  static const Color primaryMuted = Colors.white38;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late AnimationController _imageAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/3D White People_ Handyman with a Toolbox Stock Illustration - Illustration of equipment, technician_ 31893160-Photoroom.png',
      'title': 'Welcome to Bytly!',
      'subtitle': 'We bring the service\nto your doorstep.',
    },
    {
      'image': 'assets/Ualá - Plenty Studio-Photoroom.png',
      'title': 'We are the Solution to your problem',
      'subtitle':
          'Find a technician to fix your issues\nat the comfort of your home',
    },
    {
      'image': 'assets/Smiling Cartoon Mechanic Holding Wrench And Tool Box, Box Clipart, Cartoon Clipart, Wrench Clipart PNG Transparent Image and Clipart for Free Download-Photoroom.png',
      'title': 'Access Anywhere',
      'subtitle':
          'Find, pay, and rate your technician\nfrom anywhere, anytime.',
    },
    {
      'image':
          'assets/Happy Labor Day! Cartoon Wrench Fix-It-Photoroom.png',
      'title': 'Bytly app',
      'subtitle': 'Make your life easier\n with the Bytly app',
    },
  ];

  @override
  void initState() {
    super.initState();

    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _imageAnimController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _imageAnimController,
      curve: Curves.easeOutBack,
    ));

    _imageAnimController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }

  void _animateImage() {
    // Guard against overlapping restarts if onPageChanged fires
    // faster than the animation can complete (e.g. rapid swipes).
    if (!mounted) return;
    _imageAnimController.forward(from: 0);
  }

  void _skipToEnd() {
    if (_pages.isEmpty) return;
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BytlyColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (idx) {
                setState(() => _currentPage = idx);
                _animateImage();
              },
              itemBuilder: (context, idx) {
                final p = _pages[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _skipToEnd,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Image.asset(
                                  p['image']!,
                                  fit: BoxFit.contain,
                                  height: 300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              p['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _BytlyColors.primaryLight,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Dot indicators
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : _BytlyColors.primaryMuted,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),

            // Next / Get Started button
            Positioned(
              bottom: 24,
              right: 24,
              child: _currentPage == _pages.length - 1
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _BytlyColors.primary,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _goToAuth,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : FloatingActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: _BytlyColors.primary,
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}