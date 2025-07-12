import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _cityController = TextEditingController();
  final _genderController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late List<CircleData> _circles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfile();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _generateCircles() {
    final random = math.Random();
    final size = MediaQuery.of(context).size;
    _circles = List.generate(15, (i) => CircleData(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      size: random.nextDouble() * 120 + 40,
      opacity: random.nextDouble() * 0.15 + 0.05,
    ));
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _usernameController.text = response?['username'] ?? '';
        _cityController.text = response?['city'] ?? '';
        _genderController.text = response?['gender'] ?? '';
        _bioController.text = response?['bio'] ?? '';
        _emailController.text = user.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({
          'username': _usernameController.text.trim(),
          'city': _cityController.text.trim(),
          'gender': _genderController.text.trim(),
          'bio': _bioController.text.trim(),
        }).eq('id', user.id);

        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFFFFDE59)),
                const SizedBox(width: 8),
                const Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF2C3E50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
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
          // Animated Background
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
          ),

          // Floating Fashion Icons
          ...List.generate(25, (index) {
            final random = math.Random(index);
            final icons = [
              Icons.checkroom,
              Icons.dry_cleaning,
              Icons.local_laundry_service,
              Icons.accessibility_new,
              Icons.face_retouching_natural,
              Icons.style,
            ];
            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      math.sin(_animationController.value * 2 * math.pi + index) * 15,
                      math.cos(_animationController.value * 2 * math.pi + index) * 15,
                    ),
                    child: Transform.rotate(
                      angle: _animationController.value * 2 * math.pi + index,
                      child: Icon(
                        icons[index % icons.length],
                        size: 25 + random.nextDouble() * 25,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Animated Background Circles
          ..._circles.map((circle) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                left: circle.position.dx +
                    math.sin(_animationController.value * 2 * math.pi) * 25,
                top: circle.position.dy +
                    math.cos(_animationController.value * 2 * math.pi) * 25,
                child: Container(
                  width: circle.size,
                  height: circle.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFDE59).withOpacity(circle.opacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          )),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFDE59).withOpacity(0.8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF2C3E50),
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Profile...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            )
                : CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFDE59), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    centerTitle: true,
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFDE59).withOpacity(0.2),
                        border: Border.all(
                          color: const Color(0xFFFFDE59),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _isEditing ? Icons.close : Icons.edit,
                            key: ValueKey(_isEditing),
                            color: const Color(0xFFFFDE59),
                          ),
                        ),
                        onPressed: () => setState(() => _isEditing = !_isEditing),
                      ),
                    ),
                  ],
                ),

                // Profile Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Avatar
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFDE59), Color(0xFFFFD700)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFDE59).withOpacity(0.4),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF2C3E50),
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Profile Fields
                          _buildProfileCard(
                            'Personal Information',
                            Icons.person_outline,
                            [
                              _buildProfileField(
                                'Email',
                                Icons.email,
                                _emailController.text,
                                null,
                                isReadOnly: true,
                              ),
                              _buildProfileField(
                                'Username',
                                Icons.account_circle,
                                _usernameController.text,
                                _usernameController,
                              ),
                              _buildProfileField(
                                'City',
                                Icons.location_city,
                                _cityController.text,
                                _cityController,
                              ),
                              _buildProfileField(
                                'Gender',
                                Icons.person_pin,
                                _genderController.text,
                                _genderController,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _buildProfileCard(
                            'About Me',
                            Icons.info_outline,
                            [
                              _buildProfileField(
                                'Bio',
                                Icons.description,
                                _bioController.text,
                                _bioController,
                                maxLines: 3,
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Save Button
                          if (_isEditing)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 55,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFDE59), Color(0xFFFFD700)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFDE59).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                icon: _isSaving
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2C3E50),
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Icon(
                                  Icons.save,
                                  color: Color(0xFF2C3E50),
                                ),
                                label: Text(
                                  _isSaving ? 'Saving...' : 'Save Changes',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF2C3E50),
                                    fontWeight: FontWeight.bold,
                                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String title, IconData icon, List<Widget> children) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 50),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFFDE59).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(
      String label,
      IconData icon,
      String value,
      TextEditingController? controller, {
        bool isReadOnly = false,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFFDE59),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEditing && !isReadOnly && controller != null)
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'This field is required' : null,
              decoration: _buildInputDecoration(label, icon),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black.withOpacity(0.3),
                border: Border.all(
                  color: const Color(0xFFFFDE59).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                value.isEmpty ? 'Not set' : value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.white54 : Colors.white,
                  fontSize: 16,
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