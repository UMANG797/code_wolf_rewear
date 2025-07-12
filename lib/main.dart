import 'package:flutter/material.dart';
import 'package:rewear/scr/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://rsaaggdugizzkwvabivj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJzYWFnZ2R1Z2l6emt3dmFiaXZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyOTg2NjAsImV4cCI6MjA2Nzg3NDY2MH0.K-oZWiCICPg3JV3gnsuWbJNBu9lJp_YF0xugy0zI3DI' );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoarding(),
    );
  }
}
