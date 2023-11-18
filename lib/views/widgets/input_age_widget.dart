import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InputAgeWidget extends StatelessWidget {
  const InputAgeWidget(
      {super.key,
      this.hintText,
      this.labelText,
      this.controller,
      required this.obscureText,
      this.initialVal,
      this.enableTextInput});

  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final String? initialVal;
  final String? labelText;
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
        enabled: enableTextInput,

        initialValue: initialVal,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        obscureText: obscureText,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
              RegExp(r'[0-9]')), // Only allow digits and decimal point
          LengthLimitingTextInputFormatter(2)
        ],
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          labelStyle: GoogleFonts.poppins(),
          labelText: labelText,
          hintStyle: GoogleFonts.poppins(),
        ), // contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
      ),
    );
  }
}
