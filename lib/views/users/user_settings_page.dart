import 'package:denguecare_firebase/views/users/user_accountsettings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../login_page.dart';

showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled logout
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginPage()); // User confirmed logout
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
}

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: const Text('Account Settings'),
            leading: const Icon(
              Icons.person,
              color: Colors.black,
            ),
            onTap: () {
              Get.to(() => const UserAccountSettingsPage());
            },
          ),
          ListTile(
            title: const Text('Prefereneces'),
            leading: const Icon(
              Icons.checklist,
              color: Colors.black,
            ),
            onTap: () {},
          ),
          ListTile(
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            onTap: () {
              showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
