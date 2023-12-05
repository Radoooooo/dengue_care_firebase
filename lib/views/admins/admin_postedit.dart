import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:denguecare_firebase/views/admins/admin_postpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditPost extends StatefulWidget {
  final Map<String, dynamic> post;
  const AdminEditPost({super.key, required this.post});

  @override
  State<AdminEditPost> createState() => _AdminEditPostState();
}

class _AdminEditPostState extends State<AdminEditPost> {
  final FirebaseAuth aw = FirebaseAuth.instance;
  final TextEditingController _newtitleController = TextEditingController();
  final TextEditingController _newcontentController = TextEditingController();
  File? _newselectedImage;
  File? image;

  @override
  void initState() {
    super.initState();
    _newtitleController.text = widget.post['caption'];
    _newcontentController.text = widget.post['postDetails'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        leading: BackButton(
          onPressed: () {
            Get.off(() => const AdminMainPage());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              postUpload();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  widget.post['imageUrl'] != null
                      ? Image.network(
                          widget.post['imageUrl'],
                          width: 350,
                          height: 350,
                          fit: BoxFit.cover,
                        )
                      : const Placeholder(
                          fallbackHeight: 300,
                          fallbackWidth: 300,
                        ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newtitleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newcontentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                  Icons.add_photo_alternate_outlined),
                              onPressed: () {
                                imgPickUpload();
                              },
                              label: const Text('Upload an image'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void clearAllInputs() {
    setState(() {
      _newtitleController.clear();
      _newcontentController.clear();
      // other input resets if any
      _newselectedImage = null;
      imageUrl = '';
    });
  }

  void imgPickUpload() async {
    final ImagePicker picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        image = File(pickedFile.path);

        setState(() {
          _newselectedImage = image;
        });
      }
    } catch (e) {
      _showSnackbarError(context, 'Error picking image: $e');
    }
  }

  void postUpload() async {
    try {
      String? imageUrl;
      final FirebaseAuth auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (image != null) {
        String imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref =
            FirebaseStorage.instance.ref().child('images/$imageName');
        UploadTask uploadTask = ref.putFile(image!);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update the existing post in Firestore using the provided postId
      FirebaseFirestore.instance.collection('posts').doc('post_id').update({
        if (imageUrl != null) 'imageUrl': imageUrl,
        'caption': _newtitleController.text.trim(),
        'postDetails': _newcontentController.text.trim(),
      });
      //logAdminAction('Edit Post', user!.uid);
      // Clear inputs after successful update
      clearAllInputs();

      _showSnackbarSuccess(context, 'Success');
    } catch (e) {
      if (e is FirebaseException && e.code == 'storage/unauthorized') {
        _showSnackbarError(
            context, 'You do not have permission to upload images.');
      } else {
        _showSnackbarError(context, e.toString());
      }
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
