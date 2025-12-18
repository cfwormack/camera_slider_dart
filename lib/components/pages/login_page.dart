import 'package:camera_slider/components/my_textfield.dart';
import 'package:camera_slider/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  void signUserIn() async{

    showDialog(context: context, 
                  builder: (context) {return const Center(child: CircularProgressIndicator());});
    
    try {
      // Sign in the user
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    Navigator.pop(context); // Close the loading indicator
    } on FirebaseAuthException catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Incorrect email or password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 238, 249, 255),
        appBar: AppBar(
          //title: const Text('Camera Slider App'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            Text('Camera Slider Login', 
            style: TextStyle(fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Form(
                child: Column(
                  children: [
                    //username textfield
                    MyTextfield(
                      hintText: 'Enter your email',
                      labelText:'Email',
                      prefixIcon: Icons.email,
                      obscureText: false,
                      controller: emailController,
                      
                      ),
                    //password textfield
                    MyTextfield(
                      labelText:'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      controller: passwordController,
                     
                      ),
                   
                    //sign up
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    //login button
                    MyButton(onTap:  signUserIn),
                  ],
                ),
              ),
            ),
          ],
          
        ),
    );
  }
}