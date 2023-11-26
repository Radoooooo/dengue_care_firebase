import 'package:denguecare_firebase/views/users/user_homepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/post_list.dart';

class UserViewPostPage extends StatelessWidget {
  final Map<String, dynamic> post;

  const UserViewPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Details'),
          leading: BackButton(
            onPressed: () {
              Get.offAll(() => const UserMainPage());
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                conditionalImage(post['imageUrl']),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 600,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        elevation: 3,
                        child: Text(
                          post['caption'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 600,
                  height: 150,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Text(
                      post['postDetails'],
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ),
                // ... Add other details as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
