import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputConfirmPassWidget extends StatefulWidget {
  const InputConfirmPassWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.confirmController,
    required this.obscureText,
    required this.iconButton,
    this.labelText,
  });

  final String hintText;
  final TextEditingController controller;
  final TextEditingController confirmController;
  final bool obscureText;
  final IconButton iconButton;
  final String? labelText;

  @override
  _InputConfirmPassWidgetState createState() => _InputConfirmPassWidgetState();
}

class _InputConfirmPassWidgetState extends State<InputConfirmPassWidget> {
  bool _passwordsMatch = true;

  void _validatePassword() {
    setState(() {
      _passwordsMatch = widget.controller.text == widget.confirmController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            obscureText: widget.obscureText,
            controller: widget.controller,
            onChanged: (_) =>
                _validatePassword(), // Check password match on change
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: GoogleFonts.poppins(),
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: GoogleFonts.poppins(),
              suffixIcon: widget.iconButton,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            obscureText: widget.obscureText,
            controller: widget.confirmController,
            onChanged: (_) =>
                _validatePassword(), // Check password match on change
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: widget.labelText,
              hintText: 'Confirm ${widget.hintText.toLowerCase()}',
              hintStyle: GoogleFonts.poppins(),
              suffixIcon: _passwordsMatch // Display checkmark or error icon
                  ? const Icon(Icons.check)
                  : const Icon(Icons.error, color: Colors.red),
              errorText: _passwordsMatch ? null : 'Passwords do not match',
            ),
          ),
        ),
      ],
    );
  }
}
