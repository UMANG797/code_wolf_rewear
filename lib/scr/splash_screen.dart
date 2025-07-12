import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:onboarding_animation/onboarding_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'login.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  bool _showSplash = true;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late List<ClothingParticle> _particles;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _generateParticles();
    _fadeController.forward();

    Timer(const Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(15, (index) {
      return ClothingParticle(
        icon: [
          Icons.checkroom_outlined,
          Icons.dry_cleaning_outlined,
          Icons.local_laundry_service_outlined,
          Icons.accessibility_new_outlined,
          Icons.shopping_bag_outlined,
        ][random.nextInt(5)],
        startPosition: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        size: 20 + random.nextDouble() * 15,
        speed: 0.5 + random.nextDouble() * 1.5,
        opacity: 0.1 + random.nextDouble() * 0.2,
      );
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Widget _buildEnhancedWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: EnhancedWavePainter(
            waveAnimation: _waveController,
            primaryColor: const Color(0xFFFFDE59).withOpacity(0.2),
            secondaryColor: const Color(0xFF2C3E50).withOpacity(0.3),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = _particleController.value;
            final yOffset = progress * 800;
            return Positioned(
              left: particle.startPosition.dx + sin(progress * 2 * pi) * 30,
              top: particle.startPosition.dy + yOffset,
              child: Transform.rotate(
                angle: progress * 2 * pi,
                child: Icon(
                  particle.icon,
                  size: particle.size,
                  color: const Color(0xFFFFDE59).withOpacity(particle.opacity),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildEnhancedAnimatedPage(String title, String subtitle, String imagePath, List<String> features) {
    return PlayAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      delay: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 60),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern
            ...List.generate(8, (index) {
              final random = Random(index);
              return Positioned(
                left: random.nextDouble() * 400,
                top: random.nextDouble() * 800,
                child: Icon(
                  Icons.checkroom_outlined,
                  size: 40,
                  color: Colors.white.withOpacity(0.03),
                ),
              );
            }),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image container with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFDE59).withOpacity(0.1),
                          const Color(0xFFFFDE59).withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFDE59).withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFDE59), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Feature highlights
                  ...features.map((feature) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFDE59).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFFFFDE59),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C3E50),
                Color(0xFF34495E),
                Color(0xFF2C3E50),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildEnhancedWave(),
              _buildFloatingParticles(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced logo container
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFDE59).withOpacity(0.2),
                              const Color(0xFFFFDE59).withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFDE59).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset("assets/splash.png", height: 120),
                      ),
                      const SizedBox(height: 40),
                      // App name with enhanced styling
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFDE59), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "ReWear",
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline with typing animation effect
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDE59).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFFFFDE59).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "Community Clothing Exchange",
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFFFFDE59).withOpacity(0.9),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Loading indicator
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFFFDE59).withOpacity(0.8),
                          ),
                          strokeWidth: 3,
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

    return Scaffold(
      body: OnBoardingAnimation(
        pages: [
          buildEnhancedAnimatedPage(
            "Welcome to ReWear",
            "Join the sustainable fashion revolution and discover a new way to refresh your wardrobe!",
            "assets/1.gif",
            ["Eco-friendly fashion", "Community-driven", "Sustainable choices"],
          ),
          buildEnhancedAnimatedPage(
            "Swap & Earn Points",
            "Exchange your unused clothes and earn points with every successful swap you make!",
            "assets/2.gif",
            ["Point-based system", "Direct swaps", "Quality assurance"],
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF34495E),
                  Color(0xFF2C3E50),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom - 100,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Compact version of the animated page
                      PlayAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        delay: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 60),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            // Image container with reduced size
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFDE59).withOpacity(0.1),
                                    const Color(0xFFFFDE59).withOpacity(0.05),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFDE59).withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/3.gif",
                                height: 200, // Reduced from 280
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24), // Reduced spacing
                            // Title with gradient
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFFDE59), Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                "Ready to Start?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28, // Reduced from 32
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12), // Reduced spacing
                            // Subtitle
                            const Text(
                              "Begin your journey towards a more sustainable and stylish wardrobe today!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, // Reduced from 18
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20), // Reduced spacing
                            // Compact feature highlights
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: ["Zero waste fashion", "Save money", "Make new connections"]
                                  .map((feature) => Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFDE59).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFDE59).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFFFFDE59),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      feature,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      PlayAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 700),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.8 + (value * 0.2),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDE59), Color(0xFFFFD700)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFDE59).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => completeOnboarding(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                    size: 20,
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
            ),
          ),
        ],
        indicatorActiveDotColor: const Color(0xFFFFDE59),
        indicatorInActiveDotColor: Colors.white24,
        indicatorDotHeight: 10,
        indicatorDotWidth: 10,
        indicatorOffset: 20,
        indicatorType: IndicatorType.expandingDots,
        indicatorPosition: IndicatorPosition.bottomCenter,
      ),
    );
  }
}

class EnhancedWavePainter extends CustomPainter {
  final Animation<double> waveAnimation;
  final Color primaryColor;
  final Color secondaryColor;

  EnhancedWavePainter({
    required this.waveAnimation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Primary wave
    final primaryPath = Path();
    final primaryY = size.height * 0.75;
    primaryPath.moveTo(0, primaryY);

    for (var i = 0.0; i < size.width; i++) {
      primaryPath.lineTo(
        i,
        primaryY + sin((i / 40) - (waveAnimation.value * 2) * pi) * 15,
      );
    }

    primaryPath.lineTo(size.width, size.height);
    primaryPath.lineTo(0, size.height);
    primaryPath.close();

    // Secondary wave
    final secondaryPath = Path();
    final secondaryY = size.height * 0.85;
    secondaryPath.moveTo(0, secondaryY);

    for (var i = 0.0; i < size.width; i++) {
      secondaryPath.lineTo(
        i,
        secondaryY + sin((i / 60) + (waveAnimation.value * 1.5) * pi) * 10,
      );
    }

    secondaryPath.lineTo(size.width, size.height);
    secondaryPath.lineTo(0, size.height);
    secondaryPath.close();

    // Draw waves
    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(secondaryPath, secondaryPaint);
    canvas.drawPath(primaryPath, primaryPaint);
  }

  @override
  bool shouldRepaint(EnhancedWavePainter oldDelegate) => true;
}

class ClothingParticle {
  final IconData icon;
  final Offset startPosition;
  final double size;
  final double speed;
  final double opacity;

  ClothingParticle({
    required this.icon,
    required this.startPosition,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}