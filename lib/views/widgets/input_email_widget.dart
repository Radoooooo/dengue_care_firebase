import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class InputEmailWidget extends StatelessWidget {
  const InputEmailWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    this.labelText,
  });

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final String? labelText;
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
          // add email validation
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }

          bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value);
          if (!emailValid) {
            return 'Please enter a valid email';
          }

          return null;
        },
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(),
        ), // contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      ),
    );
  }
}
