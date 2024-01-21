import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/users/user_report_page.dart';
import 'package:denguecare_firebase/views/users/user_historyreports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_verifyaccountpage.dart';

class UserReportPageMenu extends StatefulWidget {
  const UserReportPageMenu({super.key});

  @override
  State<UserReportPageMenu> createState() => _UserReportPageMenuState();
}

class _UserReportPageMenuState extends State<UserReportPageMenu> {
  bool isVerified = false;
  User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    // Call a method to fetch boolean data from Firestore
    _fetchIsVerifiedData();
  }

  Future<void> _fetchIsVerifiedData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      bool fetchedIsVerified = documentSnapshot['isVerified'];

      setState(() {
        isVerified = fetchedIsVerified;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget submitButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onPressed: isVerified ? () => _buttonPressedSubmitCase() : null,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          'Submit a Case',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    Widget viewHistoryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onPressed: isVerified ? () => _buttonPressedReportHistory() : null,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          '  View History   ',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Wrap buttons in GestureDetector when isVerified is false
    if (!isVerified) {
      submitButton = GestureDetector(
        onTap: () {
          _showVerificationDialog();
          print('Hey');
        },
        child: submitButton,
      );

      viewHistoryButton = GestureDetector(
        onTap: () {
          _showVerificationDialog();
          print('Hey2');
        },
        child: viewHistoryButton,
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            submitButton,
            const SizedBox(height: 24),
            viewHistoryButton,
          ],
        ),
      ),
    );
  }

  void _buttonPressedSubmitCase() {
    Get.to(() => const UserReportPage());
  }

  void _buttonPressedReportHistory() {
    Get.to(() => const ReportsHistory());
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verification Required',
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
          ),
          content: Text(
            'Please complete the verification process.',
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => const UserVerifyAccountPage());
              },
              child: Text(
                'Proceed',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
