import 'package:denguecare_firebase/views/admins/admin_viewpost.dart';
import 'package:denguecare_firebase/views/users/user_viewpost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PostsListState createState() => _PostsListState();
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
    return Image.network(imageUrl); // or CachedNetworkImage if you prefer
  }
}

class _PostsListState extends State<PostsList> {
  getUserType(Map<String, dynamic> data) {
    //! getting user type to segregate
    User? user = FirebaseAuth.instance.currentUser;
    // ignore: unused_local_variable
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Admin") {
          Get.offAll(() => AdminViewPost(post: data));
        } else if (documentSnapshot.get('role') == "superadmin") {
          Get.offAll(() => AdminViewPost(post: data));
        } else {
          Get.offAll(() => UserViewPostPage(post: data));
        }
      } else {
        _showSnackbarError(context, 'Document does not exist on the database');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var isLargeScreen = screenSize.width > 1200;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
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
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            if (data['date'] == null) {
              // Handle the case where 'date' is null, maybe return an empty Container or another placeholder
              return Container();
            }
            // Convert the Timestamp to DateTime
            DateTime dateTime = (data['date'] as Timestamp).toDate();

            // Format the DateTime to display only the date
            String formattedDate = DateFormat('MMMMd').format(dateTime);

            return Container(
              margin: isLargeScreen
                  ? const EdgeInsets.symmetric(horizontal: 250, vertical: 20)
                  : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  getUserType(data);
                },
                child: Column(
                  children: <Widget>[
                    // ignore: avoid_unnecessary_containers
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['caption'],
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            Text(
                              formattedDate,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    AspectRatio(
                        aspectRatio: isLargeScreen ? 3 / 2 : 16 / 9,
                        child: conditionalImage(data['imageUrl'])),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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
