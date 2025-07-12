import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final locationController = TextEditingController();
  final supabase = Supabase.instance.client;
  late AnimationController _animationController;
  late List<Circle> circles = [];

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _generateCircles() {
    final random = math.Random();
    final size = MediaQuery.of(context).size;
    circles = List.generate(15, (i) => Circle(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      radius: random.nextDouble() * 30 + 10,
      color: Colors.white.withOpacity(0.1),
    ));
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bro, your passwords don’t match! Try again 💀")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        password: passwordController.text.trim(),
        email: emailController.text.trim(),
        data: {
          'username': usernameController.text.trim(),
          'location': locationController.text.trim(),
        },
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayy! Check your inbox and confirm that email 📬')),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Oops! Signup failed: ${e.message} 😵")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ugh... something went wrong: $e 🧨")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, {bool isPassword = false, VoidCallback? onToggle, bool obscureText = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFFFFDE59)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFFFDE59), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFFFDE59), width: 2),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: isPassword ? IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Color(0xFFFFDE59),
        ),
        onPressed: onToggle,
      ) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _generateCircles();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Circles
          ...circles.map((circle) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final value = _animationController.value;
              return Positioned(
                left: circle.position.dx + math.sin(value * math.pi * 2) * 20,
                top: circle.position.dy + math.cos(value * math.pi * 2) * 20,
                child: Container(
                  width: circle.radius * 2,
                  height: circle.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circle.color,
                  ),
                ),
              );
            },
          )),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.06),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.05),
                      // Logo Container (Updated to match LoginScreen)
                      Center(
                        child: Container(
                          height: size.width * 0.35,
                          width: size.width * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
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
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Title
                      Center(
                        child: Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Color(0xFFFFDE59), Colors.white],
                              ).createShader(Rect.fromLTWH(0, 0, 300, 70)),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Form Fields
                      TextFormField(
                        controller: usernameController,
                        decoration: _buildInputDecoration("Username"),
                        style: TextStyle(color: Colors.white),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Username required" : null,
                      ),
                      SizedBox(height: size.height * 0.025),

                      TextFormField(
                        controller: locationController,
                        decoration: _buildInputDecoration("Location"),
                        style: TextStyle(color: Colors.white),
                        validator: (value) =>
                        value == null || value.isEmpty ? "Location required" : null,
                      ),
                      SizedBox(height: size.height * 0.025),

                      TextFormField(
                        controller: emailController,
                        decoration: _buildInputDecoration("Email"),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value == null || !value.contains("@") ? "Invalid email" : null,
                      ),
                      SizedBox(height: size.height * 0.025),

                      TextFormField(
                        controller: passwordController,
                        decoration: _buildInputDecoration(
                          "Password",
                          isPassword: true,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          obscureText: _obscurePassword,
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        validator: (value) => value != null && value.length < 6
                            ? "Password must be at least 6 characters"
                            : null,
                      ),
                      SizedBox(height: size.height * 0.025),

                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: _buildInputDecoration(
                          "Confirm Password",
                          isPassword: true,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          obscureText: _obscureConfirmPassword,
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) =>
                        value != passwordController.text ? "Passwords don't match" : null,
                      ),
                      SizedBox(height: size.height * 0.05),

                      // Register Button
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFDE59), Colors.white],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFFDE59).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.black)
                                : Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Circle {
  final Offset position;
  final double radius;
  final Color color;

  Circle({required this.position, required this.radius, required this.color});
}