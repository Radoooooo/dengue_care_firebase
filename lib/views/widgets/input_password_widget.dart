import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputPasswordWidget extends StatelessWidget {
  const InputPasswordWidget(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.obscureText,
      required this.iconButton});

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final IconButton iconButton;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(),
            // contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            suffixIcon: iconButton),
      ),
    );
  }
}
