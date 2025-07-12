import 'dart:math' as math;
import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<CircleData> _circles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  void _generateCircles() {
    final random = math.Random();
    final size = MediaQuery.of(context).size;
    _circles = List.generate(8, (i) => CircleData(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      size: random.nextDouble() * 80 + 40,
      opacity: random.nextDouble() * 0.15,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFFDE59).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFDE59).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFDE59),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFDE59),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateCircles();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Circles
          ..._circles.map((circle) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                left: circle.position.dx +
                    math.sin(_animationController.value * 2 * math.pi) * 15,
                top: circle.position.dy +
                    math.cos(_animationController.value * 2 * math.pi) * 15,
                child: Container(
                  width: circle.size,
                  height: circle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFDE59).withOpacity(circle.opacity),
                  ),
                ),
              );
            },
          )),
          // Main Content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: const Color(0xFFFFDE59),
                              width: 1.5,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFFFDE59),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFDE59), Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.all(size.width * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSection(
                            "1. Acceptance of Terms",
                            "By downloading, installing, or using ReWear, you agree to be bound by these Terms & Conditions. If you do not agree to these terms, please do not use our application. These terms constitute a legally binding agreement between you and ReWear.",
                            Icons.handshake,
                          ),
                          _buildSection(
                            "2. User Conduct & Responsibilities",
                            "Users must not engage in illegal activities, harassment, or misuse of the platform. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to provide accurate information and update it as necessary.",
                            Icons.person_outline,
                          ),
                          _buildSection(
                            "3. Privacy & Data Protection",
                            "Your privacy is important to us. We collect and process your data in accordance with our Privacy Policy. By using ReWear, you consent to the collection and use of your information as described in our Privacy Policy. We implement appropriate security measures to protect your personal information.",
                            Icons.security,
                          ),
                          _buildSection(
                            "4. Intellectual Property",
                            "All content, features, and functionality of ReWear are owned by us and are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, or create derivative works without our express written permission.",
                            Icons.copyright,
                          ),
                          _buildSection(
                            "5. Service Availability",
                            "We strive to provide continuous service but cannot guarantee uninterrupted access. We reserve the right to modify, suspend, or discontinue any part of our service at any time. We are not liable for any interruption or discontinuation of service.",
                            Icons.cloud_done,
                          ),
                          _buildSection(
                            "6. Limitation of Liability",
                            "ReWear shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of your use of the application. Our total liability shall not exceed the amount paid by you, if any, for using our service.",
                            Icons.gavel,
                          ),
                          _buildSection(
                            "7. Account Termination",
                            "We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties. Upon termination, your right to use the service will cease immediately.",
                            Icons.cancel,
                          ),
                          _buildSection(
                            "8. Changes to Terms",
                            "We may modify these Terms & Conditions at any time. We will notify you of any changes by posting the new terms in the application. Your continued use of ReWear after such modifications constitutes your acceptance of the updated terms.",
                            Icons.update,
                          ),
                          const SizedBox(height: 32),
                          // Contact Information
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFDE59), Color(0xFFFFD700)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFDE59).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.contact_mail,
                                  color: Colors.black,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Questions or Concerns?",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Contact us at support@rewear.com",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Last updated: ${DateTime.now().toString().split(' ')[0]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
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
}

class CircleData {
  final Offset position;
  final double size;
  final double opacity;

  CircleData({
    required this.position,
    required this.size,
    required this.opacity,
  });
}