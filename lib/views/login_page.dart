import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:denguecare_firebase/views/users/user_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'users/user_registerpage.dart';
import 'widgets/input_email_widget.dart';
import 'widgets/input_password_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordNotVisible = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 118, 162, 120),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo-no-background.png'),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        InputEmailWidget(
                          hintText: "Email",
                          controller: emailController,
                          obscureText: false,
                        ),
                        const SizedBox(height: 20),
                        InputPasswordWidget(
                          hintText: "Password",
                          controller: passwordController,
                          obscureText: _isPasswordNotVisible,
                          iconButton: IconButton(
                            icon: Icon(_isPasswordNotVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isPasswordNotVisible = !_isPasswordNotVisible;
                              });
                            },
                            //padding: const EdgeInsets.symmetric(vertical: 5),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                signIn(context);
                              }
                            },
                            child: Text(
                              "Login",
                              style: GoogleFonts.poppins(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        InkWell(
                          onTap: () {
                            Get.to(() => const UserRegisterPage());
                          },
                          child: Text(
                            "Don't have an account? Sign up now!",
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCircularProgressIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future signIn(BuildContext context) async {
    try {
      _showCircularProgressIndicator();

      // Check if the user's email exists in Firestore
      bool isEmailExists = await checkUser(emailController.text.trim());

      if (isEmailExists) {
        // Check if the user is approved
        bool isUserApproved =
            await checkUser(emailController.text.trim(), checkApproval: true);

        if (isUserApproved) {
          // If email exists and user is approved, proceed with Firebase Authentication
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

          route(context);
        } else {
          _showSnackbarError(
              context, 'Your account has not been approved yet.');
        }
      } else {
        // If email does not exist in Firestore, show an error
        _showSnackbarError(context, 'Email does not exist in the database.');
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbarError(context, e.message.toString());
      Get.offAll(() => const LoginPage());
      FirebaseAuth.instance.signOut();
    } finally {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Hide CircularProgressIndicator
    }
  }

  // Future signIn(BuildContext context) async {
  //   try {
  //     _showCircularProgressIndicator();

  //     print('Before email check');
  //     bool isUserApproved =
  //         await checkUserApproval(emailController.text.trim());
  //     print('After email check: $isUserApproved');

  //     // Check if the user's email exists in Firestore
  //     print('Before email check');
  //     bool isEmailExists = await checkEmailExists(emailController.text.trim());
  //     print('After email check: $isEmailExists');

  //     if (isEmailExists && isUserApproved == true) {
  //       // If email exists in Firestore, proceed with Firebase Authentication
  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim(),
  //       );

  //       route(context);
  //     } else {
  //       // If email does not exist in Firestore, show an error
  //       _showSnackbarError(context, 'Email does not exist in the database.');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     _showSnackbarError(context, e.message.toString());
  //     Get.offAll(() => const LoginPage());
  //     FirebaseAuth.instance.signOut();
  //   } finally {
  //     Navigator.of(context, rootNavigator: true)
  //         .pop(); // Hide CircularProgressIndicator
  //   }
  // }

  // Future<bool> checkEmailExists(String email) async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .where('email', isEqualTo: email)
  //             .get();

  //     return querySnapshot.docs.isNotEmpty;
  //   } catch (error) {
  //     // Handle any potential error while querying Firestore
  //     print('Error checking email existence: $error');
  //     return false;
  //   }
  // }

  // Future<bool> checkUserApproval(String email) async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .where('email', isEqualTo: email)
  //             .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       // User with the specified email exists in the database
  //       var userDocument = querySnapshot.docs.first;
  //       bool isApproved = userDocument.get('approved') ?? false;
  //       return isApproved;
  //     } else {
  //       // User with the specified email does not exist in the database
  //       _showSnackbarError(context, 'User not approved. Contact superadmin.');
  //       return false;
  //     }
  //   } catch (error) {
  //     // Handle any potential error while querying Firestore
  //     print('Error checking user approval: $error');
  //     return false;
  //   }
  // }

  Future<bool> checkUser(String email, {bool checkApproval = false}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with the specified email exists in the database
        var userDocument = querySnapshot.docs.first;

        if (checkApproval) {
          // Check for user approval
          bool isApproved = userDocument.get('approved') ?? false;
          if (!isApproved) {
            // User not approved
            _showSnackbarError(
                context, 'User not approved. Contact superadmin.');
          }
          return isApproved;
        }

        // For email existence check
        return true;
      } else {
        // User with the specified email does not exist in the database
        _showSnackbarError(context, 'User not found.');
        return false;
      }
    } catch (error) {
      // Handle any potential error while querying Firestore
      print('Error checking user: $error');
      return false;
    }
  }

  void route(BuildContext context) async {
    if (mounted) {
      User? user = FirebaseAuth.instance.currentUser;
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (!mounted) {
          return; // Return if the widget is disposed
        }

        if (documentSnapshot.exists) {
          if (documentSnapshot.get('approved') == true) {
            if (documentSnapshot.get('role') == "Admin") {
              Get.offAll(() => const AdminMainPage());
              logAdminAction('LOG IN', user.uid);
            } else if (documentSnapshot.get('role') == "superadmin") {
              Get.offAll(() => const AdminMainPage());
              logAdminAction('LOG IN', user.uid);
            } else if (documentSnapshot.get('role') == "User") {
              Get.offAll(() => const UserMainPage());
            } else {
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginPage());
              _showSnackbarError(context, 'Invalid role for the user account.');
            }
          } else {
            FirebaseAuth.instance.signOut();
            Get.offAll(() => const LoginPage());
            _showSnackbarError(
                context, 'Your account has not been approved yet.');
          }
        } else {
          //  FirebaseAuth.instance.signOut();
          // Get.offAll(() => const LoginPage());
          _showSnackbarError(
              context, 'Document does not exist on the database');
        }
      } catch (error) {
        if (!mounted) {
          return; // Return if the widget is disposed
        }
        _showSnackbarError(context, 'An error occurred: $error');
      }
    }
  }
}

void logAdminAction(String action, String documentId) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  CollectionReference adminLogs =
      FirebaseFirestore.instance.collection('admin_logs');

  // Get the current date and time
  DateTime currentDateTime = DateTime.now();

  // Format the date and time as a string
  String formattedDateTime = "${currentDateTime.toLocal()}";

  // Create a log entry
  Map<String, dynamic> logEntry = {
    'admin_email': user?.email,
    'action': action,
    'document_id': documentId,
    'timestamp': formattedDateTime,
  };

  // Add the log entry to the 'admin_logs' collection
  await adminLogs.add(logEntry);
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
  // Future signIn(BuildContext context) async {
  //   try {
  //     _showCircularProgressIndicator();

  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim());

  //     route(context);
  //     // Navigator.of(context).pop();
  //   } on FirebaseAuthException catch (e) {
  //     _showSnackbarError(context, e.message.toString());
  //     Get.offAll(() => const LoginPage());
  //     FirebaseAuth.instance.signOut();
  //   } finally {
  //     Navigator.of(context, rootNavigator: true)
  //         .pop(); // Hide CircularProgressIndicator
  //   }
  // }

  // void route(BuildContext context) {
//   User? user = FirebaseAuth.instance.currentUser;
//   var kk = FirebaseFirestore.instance
//       .collection('users')
//       .doc(user!.uid)
//       .get()
//       .then((DocumentSnapshot documentSnapshot) {
//     if (documentSnapshot.exists) {
//       if (documentSnapshot.get('role') == "Admin") {
//         Get.offAll(() => const AdminMainPage());
//         logAdminAction('LOG IN', user.uid);
//       } else if (documentSnapshot.get('role') == "superadmin") {
//         Get.offAll(() => const AdminMainPage());
//         logAdminAction('LOG IN', user.uid);
//       } else {
//         Get.offAll(() => const UserMainPage());
//       }
//     } else {
//       _showSnackbarError(context, 'Document does not exist on the database');
//     }
//   });
// }

// void newRoute(BuildContext context) async {
//   User? user = FirebaseAuth.instance.currentUser;

//   try {
//     QuerySnapshot<Map<String, dynamic>> querySnapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             // .where('uid', isEqualTo: user!.uid)
//             .where('approved', isEqualTo: 'true')
//             .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       Map<String, dynamic> userData = querySnapshot.docs.first.data();

//       if (userData['role'] == 'Admin' || userData['role'] == 'superadmin') {
//         Get.offAll(() => const AdminMainPage());
//         logAdminAction('LOG IN', user!.uid);
//       } else {
//         Get.offAll(() => const UserMainPage());
//       }
//     } else {
//       FirebaseAuth.instance.signOut();
//       Get.offAll(() => const LoginPage());
//       _showSnackbarError(context, 'Your account has not been approved yet.');
//     }
//   } catch (e) {
//     FirebaseAuth.instance.signOut();
//     Get.offAll(() => const LoginPage());
//     _showSnackbarError(
//         context, 'Failed to get account details from the server');
//   }
// }