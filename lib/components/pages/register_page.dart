import 'package:camera_slider/components/my_textfield.dart';
import 'package:camera_slider/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {

    showDialog(context: context, 
                  builder: (context) {return const Center(child: CircularProgressIndicator());});
    
    try {
      // register the user
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context); // Close the loading indicator
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Passwords do not match'),
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
    } catch (e) {
      Navigator.pop(context);
      // Show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
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
                      hintText: 'Create your password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      controller: passwordController,
                     
                      ),
                      //confirm password textfield
                      MyTextfield(
                      labelText:'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      controller: confirmPasswordController,
                     
                      ),
                      Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          
                          Text("Already have an account? "),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              "Login Now",
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
                    MyButton(onTap:  signUserUp),
                  ],
                ),
              ),
            ),
          ],
          
        ),
    );
  }
}