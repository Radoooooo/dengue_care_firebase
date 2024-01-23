import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/users/user_accountsettings.dart';
import 'package:denguecare_firebase/views/users/user_verifyaccountpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import '../login_page.dart';

bool isVerified = false;
bool isPending = false;
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
  void initState() {
    super.initState();
    // Initialize with the first purok
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          // Update _selectedPurok if the 'purok' key exists in userData
          isVerified = userData['isVerified'];
          isPending = userData['isPending'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text('Account Settings',
                style: GoogleFonts.poppins(fontSize: 18)),
            leading: const Icon(
              Icons.person,
              color: Colors.black,
            ),
            onTap: () {
              Get.to(() => const UserAccountSettingsPage());
            },
          ),
          // Visibility(
          //   visible: !isVerified,
          //   child: ListTile(
          //     title: Text('Verify Account',
          //         style: GoogleFonts.poppins(fontSize: 18)),
          //     leading: const Icon(
          //       Icons.verified_user_sharp,
          //       color: Colors.black,
          //     ),
          //     onTap: isPending
          //         ? null
          //         : () {
          //             Get.to(() => const UserVerifyAccountPage());
          //           },
          //   ),
          // ),
          Visibility(
            visible: !isVerified || isPending,
            child: ListTile(
              title: Row(
                children: [
                  Text('Verify Account',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: isPending ? Colors.grey : Colors.black)),
                  if (isPending) // Display a badge if isPending is true
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            Colors.yellow, // You can customize the badge color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              leading: isPending
                  ? Icon(Icons.verified_user_sharp,
                      color: isPending ? Colors.grey : Colors.black)
                  : badges.Badge(
                      badgeContent: const CheckVerifiedUser(),
                      child: Icon(Icons.verified_user_sharp,
                          color: isPending ? Colors.grey : Colors.black),
                    ),
              onTap: isPending
                  ? null
                  : () {
                      Get.to(() => const UserVerifyAccountPage());
                    },
            ),
          ),
          ListTile(
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
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

class CheckVerifiedUser extends StatelessWidget {
  const CheckVerifiedUser({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the length of the ListView

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('isVerified', isEqualTo: false)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return Icon(
            Icons.warning_rounded,
            color: !isVerified ? Colors.transparent : Colors.red,
            size: 2,
          );
        }
        return const Icon(Icons.circle, size: 2, color: Colors.transparent);
      },
    );
  }
}
