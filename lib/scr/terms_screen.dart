import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms & Conditions")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            "Terms & Conditions\n\n"
                "1. Acceptance of Terms\n"
                "By using this app, you agree to these terms.\n\n"
                "2. User Conduct\n"
                "Users must not engage in illegal activities.\n\n"
                "3. Privacy Policy\n"
                "Your data is handled per our privacy policy.\n\n"
                "4. Termination\n"
                "We reserve the right to terminate accounts.\n",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}