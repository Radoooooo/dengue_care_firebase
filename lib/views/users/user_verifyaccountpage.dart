import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/users/user_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UserVerifyAccountPage extends StatefulWidget {
  const UserVerifyAccountPage({super.key});

  @override
  State<UserVerifyAccountPage> createState() => _UserVerifyAccountPageState();
}

class _UserVerifyAccountPageState extends State<UserVerifyAccountPage> {
  final uuid = const Uuid();
  String uniqueDocId = '';
  void generateUniqueId() {
    setState(() {
      uniqueDocId = uuid.v4(); // Generates a new unique ID
    });
  }

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImageAndroid;
  File? imageAndroid;
  File? imageWeb;
  XFile? pickedImageWeb;
  XFile? pickedImageAndroid;

  Uint8List? _pickedImageWeb;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    generateUniqueId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title: const Text("Verify Account"),
        leading: BackButton(
          onPressed: () {
            Get.to(() => const UserMainPage());
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Upload an ID',
                    style: GoogleFonts.poppins(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Upload an image of an ID containing proof of your residence.',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // First Placeholder for ID Upload
                  _buildIDUploadSection(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _sending = true;
                        });
                        uploadImg();
                      },
                      child: _sending == true
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Send for Verification',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildIDUploadSection() {
    return Row(
      children: [
        // ID Upload Placeholder
        Flexible(child: _buildIDUploadPlaceholder()),

        const SizedBox(width: 16),
        // Upload Button

        ElevatedButton(
          onPressed: () async => await _pickImage(),
          child: Text(
            'Select Image',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildIDUploadPlaceholder() {
    double imageSize = MediaQuery.of(context).size.width * 0.3;
    return Container(
      width: 200,
      height: 120,
      color: Colors.grey[300],
      child: Center(
        child: _pickedImageAndroid != null || _pickedImageWeb != null
            ? kIsWeb
                ? Image.memory(_pickedImageWeb!)
                : Image.file(
                    File(_pickedImageAndroid!.path),
                    fit: BoxFit.cover,
                  )
            : Icon(
                Icons.upload_file,
                size: imageSize * 0.3,
                color: Colors.grey[600],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        pickedImageWeb =
            await _imagePicker.pickImage(source: ImageSource.gallery);

        if (pickedImageWeb != null) {
          _pickedImageWeb = await pickedImageWeb!.readAsBytes();
          setState(() {
            _pickedImageWeb;
          });
          _showSnackbarSuccess(context, "Image Selected");
        }
      } else if (Platform.isAndroid) {
        final pickedImageAndroid =
            await _imagePicker.pickImage(source: ImageSource.gallery);

        if (pickedImageAndroid != null) {
          imageAndroid = File(pickedImageAndroid.path);
          setState(() {
            _pickedImageAndroid = imageAndroid;
          });
        } else {
          _showSnackbarError(context, 'No image selected');
        }
      }
    } catch (e) {
      _showSnackbarError(context, e.toString());
    }
  }

  void uploadImg() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    try {
      if (kIsWeb) {
        String? downloadURL;
        if (pickedImageWeb != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef =
              storageRef.child('IDsforVerification/${pickedImageWeb!.name}');
          await imageRef.putData(
              _pickedImageWeb!, SettableMetadata(contentType: 'image/jpeg'));
          downloadURL = await imageRef.getDownloadURL();
        } else if (pickedImageWeb == null) {
          downloadURL = '';
        }
        FirebaseFirestore.instance.collection('forVerification').add({
          if (downloadURL != null) 'imageUrl': downloadURL,
          if (downloadURL == null) 'imageUrl': '',
          'uploaderEmail': user!.email,
          'uploaderUID': user.uid,
          'post_id': uniqueDocId,
          'date': FieldValue.serverTimestamp(),
          'status': false,
        });
        _showConfirmationDialog();
      } else if (Platform.isAndroid) {
        String? imageUrl;
        if (_pickedImageAndroid != null) {
          String imageName =
              'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final ref = FirebaseStorage.instance
              .ref()
              .child('IDsforVerification/$imageName');
          UploadTask uploadTask = ref.putFile(_pickedImageAndroid!);
          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          imageUrl = await snapshot.ref.getDownloadURL();
        } else if (_pickedImageAndroid == null) {
          imageUrl = '';
        }
        FirebaseFirestore.instance.collection('forVerification').add({
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (imageUrl == null) 'imageUrl': '',
          'uploaderEmail': user!.email,
          'uploaderUID': user.uid,
          'post_id': uniqueDocId,
          'date': FieldValue.serverTimestamp(),
          'status': false,
        });
        _showConfirmationDialog();
      }
    } catch (e) {
      _showSnackbarError(context, e.toString());
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Verification Request Sent!',
            style: GoogleFonts.poppins(
              fontSize: 24,
            ),
          ),
          content: Text(
            'We ask for your understanding as we validate your request.',
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
                'OK',
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
