import 'package:camera_slider/components/pages/home_page.dart';
import 'package:camera_slider/components/pages/register_or_login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Replace with your widget tree based on the snapshot
          if (snapshot.hasData) {
            //Logged in
            return HomePage();
          } else {
            //not logged in
            return RegisterOrLoginPage();
          }
        },
      ),
    );
  }
}