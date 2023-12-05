import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/post_list.dart';

//! FOR MOBILE
File? image;
File? _selectedImage;

//! WEB
List<Uint8List> pickedImagesInBytes = [];
XFile? imagefromWeb;

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
  Uint8List? bytes;
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
            clearAllInputs();
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
            icon: const Icon(Icons.edit_square),
          ),
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
              isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: captionController,
                        decoration: const InputDecoration(labelText: 'Caption'),
                      ),
                    )
                  : SizedBox(
                      width: 600,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            elevation: 3,
                            child: Text(
                              widget.post['caption'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
              isEditing
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: postDetailsController,
                        decoration:
                            const InputDecoration(labelText: 'Post Details'),
                      ),
                    )
                  : SizedBox(
                      width: 600,
                      height: 150,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Text(
                          widget.post['postDetails'],
                          textAlign: TextAlign.left,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                    ),
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      onPressed: () async {
                        if (kIsWeb) {
                          uploadimgWeb();
                        } else if (Platform.isAndroid) {
                          postUpload();
                        }
                      },
                      label: const Text('Save Changes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined),
                      onPressed: () async {
                        if (widget.post['uploaderUID'] ==
                            FirebaseAuth.instance.currentUser!.uid) {
                          deleteFileByURL(widget.post['imageUrl']);
                          _confirmDelete(context);
                        } else {
                          _showSnackbarError(context, 'Unauthorized Action');
                        }
                      },
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                      label: const Text('Delete Post'),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void clearAllInputs() {
    setState(() {
      bytes = null;
      _selectedImage = null;
      downloadURL = '';
    });
  }

  Future<String> getDocumentID() async {
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

  Future<String> fetchDocumentID() async {
    return await getDocumentID();
  }

  Future<void> deletePost() async {
    try {
      String postIDRef = await fetchDocumentID();
      CollectionReference reports =
          FirebaseFirestore.instance.collection('posts');
      DocumentReference userDocRef = reports.doc(postIDRef);

      userDocRef.delete();

      _showSnackbarSuccess(context, 'Post Deleted');
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
        'uploaderEmail': user!.email,
        'uploaderUID': user.uid,
        'date': FieldValue.serverTimestamp(),
      });
      logAdminAction('Edit Post', user.uid);
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
        deleteFileByURL(widget.post['imageUrl']);
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
      String? imageUrl;

      if (bytes != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('images/${imagefromWeb!.name}');

        await imageRef.putData(
            bytes!, SettableMetadata(contentType: 'image/jpeg'));

        imageUrl = await imageRef.getDownloadURL();
      }

      setState(() {
        downloadURL = imageUrl ?? widget.post['imageUrl'];
      });

      FirebaseFirestore.instance.collection('posts').doc(postID).update({
        if (imageUrl != null) 'imageUrl': imageUrl,
        'caption': captionController.text.trim(),
        'postDetails': postDetailsController.text.trim(),
        'uploaderEmail': user!.email,
        'uploaderUID': user.uid,
        'date': FieldValue.serverTimestamp(),
      });

      setState(() {
        widget.post['caption'] = captionController.text.trim();
        widget.post['postDetails'] = postDetailsController.text.trim();
        isEditing = false;
      });
      logAdminAction('Edit Post', user.uid);

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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deletePost();
                Navigator.of(context).pop();
                Get.offAll(() => const AdminMainPage());
              },
              child: const Text('Delete'),
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
