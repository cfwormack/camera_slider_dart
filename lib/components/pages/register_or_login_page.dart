import 'package:camera_slider/components/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:camera_slider/components/pages/register_page.dart';

class RegisterOrLoginPage extends StatefulWidget {
  const RegisterOrLoginPage({super.key});
  
  @override
  State<RegisterOrLoginPage> createState() => _RegisterOrLoginPageState();
}

class _RegisterOrLoginPageState extends State<RegisterOrLoginPage> {
  bool isRegisteredUser = true; // Change this to false to show LoginPage
  void togglePage() {
    setState(() {
      isRegisteredUser = !isRegisteredUser;
    });
  }
  @override
  Widget build(BuildContext context) {
   if (isRegisteredUser) {
      return LoginPage(onTap: togglePage);
    } 
    else{
      return RegisterPage(onTap: togglePage);
    }
  }
}