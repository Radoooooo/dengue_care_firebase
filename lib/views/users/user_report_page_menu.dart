import 'package:denguecare_firebase/views/users/user_report_page.dart';
import 'package:denguecare_firebase/views/users/user_historyreports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UserReportPageMenu extends StatefulWidget {
  const UserReportPageMenu({super.key});

  @override
  State<UserReportPageMenu> createState() => _UserReportPageMenuState();
}

class _UserReportPageMenuState extends State<UserReportPageMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                Get.to(() => const UserReportPage());
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Submit a Case',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                Get.to(() => const ReportsHistory());
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '  View History   ',
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
