import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_verifyuser_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VerificationList extends StatefulWidget {
  const VerificationList({super.key});

  @override
  State<VerificationList> createState() => _VerificationListState();
}

Widget conditionalImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    // Show a placeholder or any other widget when there's no image
    return Container(
      width: double.maxFinite,
      // height: isLargeScreen ? 200.0 : 150.0, // Adjust the height as needed
      color: Colors.grey, // Placeholder color
      child: const Icon(
        Icons.image_not_supported,
        size: 50.0,
        color: Colors.white, // Placeholder icon color
      ),
    );
  }
  if (kIsWeb) {
    // If the platform is web
    return Image.network(
      imageUrl,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.maxFinite,
          color: Colors.grey,
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    (loadingProgress.expectedTotalBytes ?? 1)
                : null,
          ),
        );
      },
      fit: BoxFit.cover,
    );
  } else if (Platform.isAndroid) {
    // If the platform is Android
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) {
        // Check if the error is due to the image not being found
        if (error is Error) {
          String errorString = error.toString().toLowerCase();
          if (errorString.contains('404') ||
              errorString.contains('not found')) {
            return Container(
              width: double.maxFinite,
              color: Colors.grey,
              child: const Icon(
                Icons.error,
                size: 50.0,
                color: Colors.white,
              ),
            );
          }
        }
        // If it's a different error, you can handle it accordingly
        return Container(
          width: double.maxFinite,
          color: Colors.grey,
          child: const Icon(
            Icons.error,
            size: 50.0,
            color: Colors.white,
          ),
        );
      },
    );
  } else {
    // For other platforms (like iOS)
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
    ); // or CachedNetworkImage if you prefer
  }
}

class _VerificationListState extends State<VerificationList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('forVerification')
            .where('status', isEqualTo: false)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              if (data['date'] == null) {
                // Handle the case where 'date' is null, maybe return an empty Container or another placeholder
                return Container();
              }
              // Convert the Timestamp to DateTime
              DateTime dateTime = (data['date'] as Timestamp).toDate();

              // Format the DateTime to display only the date
              String formattedDate =
                  DateFormat.yMMMMd('en_US').format(dateTime);

              return Card(
                child: InkWell(
                  onTap: () {
                    Get.offAll(() => AdminConfirmationPage(post: data));
                  },
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 100,
                        minHeight: 100,
                        maxWidth: 200,
                        maxHeight: 200,
                      ),
                      child: conditionalImage(data['imageUrl']),
                    ),
                    title: Text(data['uploaderEmail'],
                        style: GoogleFonts.poppins(fontSize: 16)),
                    subtitle: Text(formattedDate, style: GoogleFonts.poppins()),
                  ),
                ),
              );
            }).toList(),
          );
        });
  }
}

//!!!!! NEW CLASS

class AdminConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const AdminConfirmationPage({super.key, required this.post});

  @override
  State<AdminConfirmationPage> createState() => _AdminConfirmationPageState();
}

class _AdminConfirmationPageState extends State<AdminConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const AdminVerifyUserPage());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Container to display the large image
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    maxWidth: double.infinity,
                  ),
                  child: Image.network(
                    widget.post['imageUrl'],
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    fit: BoxFit.contain, // Fit the image within the constraints
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () {
                            _showConfirmationDialog();
                          },
                          child: Text(
                            "Approve",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                              backgroundColor: Colors.red),
                          onPressed: () {
                            _showRejectionDialog();
                          },
                          child: Text(
                            "Reject",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                // Other details or widgets can be added here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getPostID() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('forVerification');

    QuerySnapshot querySnapshot = await collectionRef
        .where('post_id', isEqualTo: widget.post['post_id'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot document = querySnapshot.docs[0];
      String documentID = document.id;
      return documentID;
    } else {
      return "No matching documents found";
    }
  }

  Future<String> fetchPostID() async {
    return await getPostID();
  }

  Future<String> getDocumentID() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    QuerySnapshot querySnapshot = await collectionRef
        .where('email', isEqualTo: widget.post['uploaderEmail'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot document = querySnapshot.docs[0];
      String documentID = document.id;
      print(documentID);
      return documentID;
    } else {
      return "No matching documents found";
    }
  }

  Future<String> fetchDocumentID() async {
    return await getDocumentID();
  }

  Future<String> getDocumentIDforVerification() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('forVerification');

    QuerySnapshot querySnapshot = await collectionRef
        .where('uploaderEmail', isEqualTo: widget.post['uploaderEmail'])
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot document = querySnapshot.docs[0];
      String documentID = document.id;
      print(documentID);
      return documentID;
    } else {
      return "No matching documents found";
    }
  }

  Future<String> fetchDocumentIDforVerification() async {
    return await getDocumentIDforVerification();
  }

  void updateVerificationStatus() async {
    String postID = await fetchPostID();
    String docID = await fetchDocumentID();
    try {
      await FirebaseFirestore.instance
          .collection('forVerification')
          .doc(postID)
          .update({'status': true});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(docID)
          .update({'isVerified': true});
      print('Status updated successfully.');
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Approval',
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
          ),
          content: Text(
            'Please Confirm Approval',
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.back();
              },
              child: Text(
                'Cancel,',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                updateVerificationStatus();
                Get.offAll(() => const AdminVerifyUserPage());
                _showSnackbarSuccess(context, 'Confirmation Successful');
              },
              child: Text(
                'Confirm,',
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

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Rejection',
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
          ),
          content: Text(
            'You are about to reject this request.',
            style: GoogleFonts.poppins(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.back();
              },
              child: Text(
                'Cancel,',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteRequest();
                deleteFileByURL(widget.post['imageUrl']);
                Get.offAll(() => const AdminVerifyUserPage());
                _showSnackbarSuccess(context, 'Action Successful');
              },
              child: Text(
                'Confirm,',
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

  Future<void> deleteRequest() async {
    try {
      String requestIDref = await fetchDocumentIDforVerification();
      CollectionReference reports =
          FirebaseFirestore.instance.collection('forVerification');
      DocumentReference userDocRef = reports.doc(requestIDref);

      userDocRef.delete();

      _showSnackbarSuccess(context, 'Request Deleted');
    } catch (e) {
      _showSnackbarError(context, e.toString());
    }
  }

  Future<void> deleteFileByURL(String imgUrl) async {
    try {
      if (imgUrl.isNotEmpty) {
        // Create a reference to the file based on the download URL
        Reference storageReference =
            FirebaseStorage.instance.refFromURL(imgUrl);

        // Delete the file
        await storageReference.delete();

        print('File deleted successfully');
      } else {
        print('Image URL is empty. No file deleted.');
      }
    } catch (e) {
      print('Error deleting file: $e');
      _showSnackbarError(context, e.toString());
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
}
