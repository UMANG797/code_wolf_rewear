import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rewear/scr/register%20page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  bool obscurePassword = true;
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
    _circles = List.generate(12, (i) => CircleData(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      size: random.nextDouble() * 100 + 50,
      opacity: random.nextDouble() * 0.2,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Check credentials.')),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFFFDE59)),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFDE59), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFDE59), width: 2),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.7),
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateCircles();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Clothing Pattern Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C3E50), // Deep blue-gray
                  Color(0xFF34495E), // Darker blue-gray
                  Color(0xFF2C3E50), // Deep blue-gray
                ],
              ),
            ),
          ),
          // Clothing Icons Pattern
          ...List.generate(20, (index) {
            final random = math.Random(index);
            final icons = [
              Icons.checkroom,
              Icons.dry_cleaning,
              Icons.local_laundry_service,
              Icons.accessibility_new,
            ];
            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_animationController.value * 2 * math.pi + index) * 10,
                      math.cos(_animationController.value * 2 * math.pi + index) * 10,
                    ),
                    child: Icon(
                      icons[index % icons.length],
                      size: 30 + random.nextDouble() * 20,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  );
                },
              ),
            );
          }),
          // Animated Background Circles (clothing themed colors)
          ..._circles.map((circle) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                left: circle.position.dx +
                    math.sin(_animationController.value * 2 * math.pi) * 20,
                top: circle.position.dy +
                    math.cos(_animationController.value * 2 * math.pi) * 20,
                child: Container(
                  width: circle.size,
                  height: circle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFDE59).withOpacity(circle.opacity * 0.3),
                  ),
                ),
              );
            },
          )),
          // Fabric Texture Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(size.width * 0.06),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    // Logo Container
                    Container(
                      height: size.width * 0.35,
                      width: size.width * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2C3E50),
                        border: Border.all(
                          color: const Color(0xFFFFDE59),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFDE59).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/splash.png',
                          fit: BoxFit.contain,
                          height: size.width * 0.35,
                          width: size.width * 0.35,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // Welcome Text
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFDE59), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        "Welcome Back!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Subtitle
                    const Text(
                      "ReWear - Your Sustainable Fashion Community",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    // Email Field
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration("Email", Icons.email),
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Password Field
                    TextField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: obscurePassword,
                      decoration: _buildInputDecoration("Password", Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFFFFDE59),
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    // Login Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 55,
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
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),
                    // Register Link
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Color(0xFFFFDE59),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
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