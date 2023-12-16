import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_manageadmin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAccountApprovalPage extends StatefulWidget {
  const AdminAccountApprovalPage({super.key});

  @override
  State<AdminAccountApprovalPage> createState() =>
      _AdminAccountApprovalPageState();
}

class _AdminAccountApprovalPageState extends State<AdminAccountApprovalPage> {
  final CollectionReference user =
      FirebaseFirestore.instance.collection('users');

  Future<void> _updateApprovalStatus(String userId) async {
    try {
      // Get the reference to the document in the 'users' collection
      DocumentReference userDocument = user.doc(userId);

      // Update the 'approved' field to true
      await userDocument.update({'approved': true});

      // Show success message using the provided _showSnackbarSuccess function
      _showSnackbarSuccess(context, "User Approved Successfully");
    } catch (error) {
      // Show error message using the provided _showSnackbarError function
      _showSnackbarError(context, "Error updating approval status: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title: Text("Admin Accounts for Approval",
            style: GoogleFonts.poppins(fontSize: 20)),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const ManageAdmin());
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: user
            .where('role', isEqualTo: 'Admin')
            .where('approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: $snapshot.error"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("No Admin found",
                    style: GoogleFonts.poppins(fontSize: 16)));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot ds = snapshot.data!.docs[index];
                return Card(
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(children: [
                        const WidgetSpan(
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        const TextSpan(text: '   '),
                        TextSpan(
                          text: ds['firstName'],
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: ds['lastName'],
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black),
                        ),
                      ]),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.email,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(text: '   '),
                            TextSpan(
                                text: ds['email'],
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            const WidgetSpan(
                              child: Icon(
                                Icons.contact_phone,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(text: '   '),
                            TextSpan(
                                text: ds['contact_number'],
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Approval"),
                              content: const Text("Confirm Approval"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    //update function here
                                    _updateApprovalStatus(ds.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
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
