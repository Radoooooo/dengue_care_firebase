import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/post_list.dart';

//! FOR MOBILE
File? image;
File? _selectedImage;

//! WEB
List<Uint8List> pickedImagesInBytes = [];
XFile? imagefromWeb;
Uint8List? bytes;

class AdminViewPost extends StatefulWidget {
  final Map<String, dynamic> post;

  const AdminViewPost({super.key, required this.post});

  @override
  State<AdminViewPost> createState() => _AdminViewPostState();
}

class _AdminViewPostState extends State<AdminViewPost> {
  late TextEditingController captionController;
  late TextEditingController postDetailsController;
  bool isEditing = false;
  String downloadURL = '';
  @override
  void initState() {
    super.initState();
    captionController = TextEditingController(text: widget.post['caption']);
    postDetailsController =
        TextEditingController(text: widget.post['postDetails']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const AdminMainPage());
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
              icon: const Icon(Icons.edit_square))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 8.0),
              SizedBox(
                width: 500,
                height: 450,
                child: _selectedImage != null || bytes != null
                    ? kIsWeb
                        ? Image.memory(
                            bytes!,
                            width: 350,
                            height: 350,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _selectedImage!,
                            width: 350,
                            height: 350,
                            fit: BoxFit.cover,
                          )
                    : conditionalImage(widget.post['imageUrl']),
              ),
              const SizedBox(height: 8.0),
              if (isEditing)
                Wrap(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton.icon(
                            icon:
                                const Icon(Icons.add_photo_alternate_outlined),
                            onPressed: () async {
                              if (kIsWeb) {
                                await _pickImageWeb();
                              } else if (Platform.isAndroid) {
                                imgPickUpload();
                              }
                            },
                            label: const Text('Change image'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: captionController,
                        decoration: const InputDecoration(labelText: 'Caption'),
                      ),
                    )
                  : Text(widget.post['caption']),
              const SizedBox(height: 8.0),
              isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: postDetailsController,
                        decoration:
                            const InputDecoration(labelText: 'Post Details'),
                      ),
                    )
                  : Text(widget.post['postDetails']),
              if (isEditing)
                ElevatedButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      uploadimgWeb();
                    } else if (Platform.isAndroid) {
                      postUpload();
                    }
                  },
                  child: const Text('Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteFileByURL(String imgUrl) async {
    try {
      // Create a reference to the file based on the download URL
      Reference storageReference = FirebaseStorage.instance.refFromURL(imgUrl);

      // Delete the file
      await storageReference.delete();

      print('File deleted successfully');

      // _showSnackbarSuccess(context, 'File deleted successfully');
    } catch (e) {
      print('Error deleting file: $e');
      _showSnackbarError(context, e.toString());
    }
  }

  void postUpload() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    String postID = await fetchPostID();
    try {
      String? imageUrl;

      if (image != null) {
        String imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref =
            FirebaseStorage.instance.ref().child('images/$imageName');
        UploadTask uploadTask = ref.putFile(image!);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      FirebaseFirestore.instance.collection('posts').doc(postID).update({
        if (imageUrl != null) 'imageUrl': imageUrl,
        'caption': captionController.text.trim(),
        'postDetails': postDetailsController.text.trim(),
        'uploaderEmail':
            user!.email, // Assuming the displayName is set for Firebase user.
        'uploaderUID': user.uid,
        'date': FieldValue.serverTimestamp(),
      });
      _showSnackbarSuccess(context, 'Success');
      setState(() {
        widget.post['caption'] = captionController.text.trim();
        widget.post['postDetails'] = postDetailsController.text.trim();
        isEditing = false;
      });
    } catch (e) {
      print(e.toString());
      _showSnackbarError(context, e.toString());
    }
  }

  void imgPickUpload() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    try {
      if (pickedFile != null) {
        deleteFileByURL(widget.post['imgUrl']);
        image = File(pickedFile.path);

        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showSnackbarError(context, e.toString());
    }
  }

  Future<void> _pickImageWeb() async {
    try {
      ImagePicker picker = ImagePicker();
      imagefromWeb = await picker.pickImage(source: ImageSource.gallery);

      if (imagefromWeb != null) {
        deleteFileByURL(widget.post['imageUrl']);
        bytes = await imagefromWeb!.readAsBytes();
        setState(() {
          bytes;
        });

        _showSnackbarSuccess(context, "Image Selected");
      }
    } catch (e) {
      _showSnackbarError(context, e.toString());
    }
  }

  void uploadimgWeb() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    String postID = await fetchPostID();
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('images/${imagefromWeb!.name}');

      await imageRef.putData(
          bytes!, SettableMetadata(contentType: 'image/jpeg'));

      final String downloadURL = await imageRef.getDownloadURL();

      setState(() {
        this.downloadURL = downloadURL;
      });
      FirebaseFirestore.instance.collection('posts').doc(postID).update({
        'imageUrl': downloadURL,
        'caption': captionController.text.trim(),
        'postDetails': postDetailsController.text.trim(),
        'uploaderEmail':
            user!.email, // Assuming the displayName is set for Firebase user.
        'uploaderUID': user.uid,
        'date': FieldValue.serverTimestamp(),
      });
      logAdminAction('Created Post', user.uid);
      _showSnackbarSuccess(context, 'Success');
    } catch (e) {
      _showSnackbarError(context, e.toString());
    }
  }

  Future<String> getPostID() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('posts');

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
