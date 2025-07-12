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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Widget _buildWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            waveAnimation: _waveController,
            waveColor: const Color(0xFFFFDE59).withOpacity(0.3),
          ),
        );
      },
    );
  }

  Widget buildAnimatedPage(String title, String subtitle, String imagePath) {
    return PlayAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 50),
            child: child,
          ),
        );
      },
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 300, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFDE59),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _buildWave(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Image.asset("assets/splash.png", height: 150),
                    ),
                    const SizedBox(height: 30),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFDE59), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        "ReWear",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Sustainable Fashion Revolution",
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFFFFDE59).withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: OnBoardingAnimation(
        pages: [
          buildAnimatedPage(
            "Welcome to ClosetX",
            "Discover a new way to refresh your wardrobe!",
            "assets/1.gif",
          ),
          buildAnimatedPage(
            "Swap & Save",
            "Earn points with every clothing swap you make!",
            "assets/2.gif",
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildAnimatedPage(
                "Get Started Now",
                "Start your journey towards sustainable fashion!",
                "assets/3.gif", // New GIF asset
              ),
              const SizedBox(height: 40),
              PlayAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () => completeOnboarding(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDE59),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
        indicatorActiveDotColor: const Color(0xFFFFDE59),
        indicatorInActiveDotColor: Colors.white24,
        indicatorDotHeight: 8,
        indicatorDotWidth: 8,
        indicatorOffset: 15,
        indicatorType: IndicatorType.expandingDots,
        indicatorPosition: IndicatorPosition.bottomCenter,
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> waveAnimation;
  final Color waveColor;

  WavePainter({required this.waveAnimation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final y = size.height * 0.8;
    path.moveTo(0, y);

    for (var i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        y + sin((i / 30) - (waveAnimation.value * 2) * pi) * 10,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}