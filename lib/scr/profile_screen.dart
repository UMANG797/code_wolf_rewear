import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _cityController = TextEditingController();
  final _genderController = TextEditingController();

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
      _usernameController.text = response['username'] ?? '';
      _cityController.text = response['city'] ?? '';
      _genderController.text = response['gender'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('profiles')
            .update({
          'username': _usernameController.text.trim(),
          'city': _cityController.text.trim(),
          'gender': _genderController.text.trim(),
        })
            .eq('id', user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (value) => value?.isEmpty ?? true ? "Enter username" : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
                validator: (value) => value?.isEmpty ?? true ? "Enter city" : null,
              ),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(labelText: "Gender"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text("Update Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}