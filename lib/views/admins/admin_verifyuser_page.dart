import 'package:denguecare_firebase/views/widgets/verification_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_homepage.dart';

class AdminVerifyUserPage extends StatefulWidget {
  const AdminVerifyUserPage({super.key});

  @override
  State<AdminVerifyUserPage> createState() => _AdminVerifyUserPageState();
}

class _AdminVerifyUserPageState extends State<AdminVerifyUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title: Text("Admin List", style: GoogleFonts.poppins(fontSize: 20)),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const AdminMainPage());
          },
        ),
      ),
      body: const VerificationList(),
    );
  }
}
