import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_accountapprovalpage.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:denguecare_firebase/views/admins/admin_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageAdmin extends StatefulWidget {
  const ManageAdmin({super.key});

  @override
  State<ManageAdmin> createState() => _ManageAdminState();
}

class _ManageAdminState extends State<ManageAdmin> {
  final CollectionReference user =
      FirebaseFirestore.instance.collection('users');

  Future<void> deleteUserData(String email) async {
    try {
      // Step 1: Query Firestore to get the document associated with the email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Error: No user found in Firestore with email $email");
        return;
      }

      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      String documentId = documentSnapshot.id;

      // Step 2: Get UID from Firestore data
      String? uid = documentSnapshot['document_id'];

      if (uid == null) {
        print(
            "Error: 'uid' is null or does not exist for the user with email $email");
        return;
      }

      // Step 3: Delete User from Firebase Authentication
      try {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null && currentUser.uid == uid) {
          await currentUser.delete();
          print("User deleted from Authentication");
        } else {
          print("Error: Current user not matching the user to be deleted");
        }
      } catch (e) {
        print("Error deleting user from Authentication: $e");
      }

      // Step 4: Delete User Data from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(documentId)
          .delete();

      print("Admin with email $email deleted successfully");
    } catch (e) {
      print("Error deleting admin: $e");
    }
  }

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
        actions: [
          IconButton(
            onPressed: () {
              Get.offAll(const AdminAccountApprovalPage());
            },
            icon: const Icon(Icons.person_add_alt_1),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: user
            .where('role', isEqualTo: 'Admin')
            .where('approved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: $snapshot.error"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Admin found"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot ds = snapshot.data!.docs[index];
                return Card(
                  child: ListTile(
                    title: Text("${ds['firstName']} ${ds['lastName']}",
                        style: GoogleFonts.poppins(fontSize: 16)),
                    subtitle: Text(ds['contact_number'],
                        style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete User"),
                              content: const Text(
                                  "Are you sure you want to delete this user?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteUserData(ds['email']);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Delete"),
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
