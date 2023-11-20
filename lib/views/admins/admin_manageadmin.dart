import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:denguecare_firebase/views/admins/admin_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageAdmin extends StatefulWidget {
  const ManageAdmin({super.key});

  @override
  State<ManageAdmin> createState() => _ManageAdminState();
}

class _ManageAdminState extends State<ManageAdmin> {
  final CollectionReference user =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title: const Text("Admin List"),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const AdminMainPage());
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.offAll(const AdminRegisterPage());
            },
            icon: const Icon(Icons.person_add),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: user.where('role', isEqualTo: 'Admin').snapshots(),
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
                    title: Text(ds['name']),
                    subtitle: Text(ds['contact_number']),
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
                                    ds.reference.delete();
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
