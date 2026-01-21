import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String? hintText;
  final controller;
  final bool? obscureText;
  final IconData? prefixIcon;

  final String? labelText;

  const MyTextfield({super.key, this.labelText,this.hintText, this.controller, this.obscureText,this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child: TextFormField(
                        controller: controller,
                        obscureText: obscureText ?? false,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelText: labelText,
                          hintText: hintText,

                          prefixIcon: Icon(prefixIcon),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your $labelText';
                          }
                          // Add more validation if needed
                          return null;
                        },
                      ),
              
                    );
  }
}