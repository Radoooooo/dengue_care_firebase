import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class InputAddressWidget extends StatelessWidget {
  const InputAddressWidget({
    super.key,
    required this.labelText,
    this.controller,
    required this.obscureText,
    this.initialVal,
    this.enableTextInput,
  });

  final String labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? initialVal;
  final bool? enableTextInput;

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
            return 'This field is required';
          }
          return null;
        },
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        obscureText: obscureText,
        initialValue: initialVal,
        controller: controller,
        enabled: enableTextInput,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(),
          //hintText: hintText,
          hintStyle: GoogleFonts.poppins(),
        ), // contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      ),
    );
  }
}
