import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InputContactNumber extends StatelessWidget {
  const InputContactNumber({
    super.key,
    this.hintText,
    this.controller,
    required this.obscureText,
    this.initialVal,
    this.enableTextInput,
    this.labelText,
  });

  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? initialVal;
  final bool? enableTextInput;
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
        inputFormatters: [
          //LengthLimitingTextInputFormatter(10),
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: 10,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        obscureText: obscureText,
        initialValue: initialVal,
        controller: controller,
        enabled: enableTextInput,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 14),
        ), // contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      ),
    );
  }
}
