import 'package:denguecare_firebase/charts/testchart.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
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
      body: Card(
        child: ListTile(
          title: Text(
            'Clear Data',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          subtitle: Text('Delete Dengue Line List Data',
              style: GoogleFonts.poppins(fontSize: 12)),
          trailing: IconButton(
            onPressed: () {
              _showConfirmDialog(context);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title:
            Text('Clearing Data...', style: GoogleFonts.poppins(fontSize: 20)),
        content: const CircularProgressIndicator(),
      ),
    );
  }

  void dismissLoadingDialog() {
    Navigator.of(context).pop();
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Dengue Line List Data',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              'You are about to delete dengue line list data.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  chart = [];
                  chart2 = [];
                  chart3 = [];
                  barChart = [];
                  pieChart = [];
                  yearlyData = [];
                  yearlySeries = [];
                  hAgeGroup = '';
                  lAgeGroup = '';

                  a1 = 0;
                  a2 = 0;
                  a3 = 0;
                  a4 = 0;
                });
                showLoadingDialog();
                await deleteAllDocumentsInCollection('denguelinelist');
                dismissLoadingDialog();
                _showSnackbarSuccess(context, "Success");
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbarError(BuildContext context, String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _showSnackbarSuccess(BuildContext context, String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
