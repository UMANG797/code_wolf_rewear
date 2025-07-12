import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _cityController = TextEditingController();
  final _genderController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _usernameController.text = response['username'] ?? '';
        _cityController.text = response['city'] ?? '';
        _genderController.text = response['gender'] ?? '';
        _bioController.text = response['bio'] ?? '';
        _emailController.text = user.email ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update({
          'username': _usernameController.text.trim(),
          'city': _cityController.text.trim(),
          'gender': _genderController.text.trim(),
          'bio': _bioController.text.trim(),
        }).eq('id', user.id);

        setState(() => _isEditing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile updated successfully!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInfoTile("Email", _emailController.text, editable: false),
              const SizedBox(height: 12),
              _buildTextField("Username", _usernameController),
              const SizedBox(height: 12),
              _buildTextField("City", _cityController),
              const SizedBox(height: 12),
              _buildTextField("Gender", _genderController),
              const SizedBox(height: 12),
              _buildTextField("Bio", _bioController, maxLines: 2),
              const SizedBox(height: 20),
              if (_isEditing)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  onPressed: _updateProfile,
                  child: const Text("Save Changes"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {bool editable = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value.isEmpty ? "Not set" : value),
        )
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null,
    );
  }
}
