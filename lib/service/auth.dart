import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../scr/home.dart';
import '../scr/login.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          var session= Supabase.instance.client.auth.currentSession;

          if(session==null)
            {
              return  const LoginScreen();
            }
          else{
            return const HomeScreen();
          }
        },);
  }
}
