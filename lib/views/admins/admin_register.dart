import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_manageadmin.dart';
import 'package:denguecare_firebase/views/widgets/input_age_widget.dart';
import 'package:denguecare_firebase/views/widgets/input_confirmpass_widget.dart';
import 'package:denguecare_firebase/views/widgets/input_contact_number.dart';
import 'package:denguecare_firebase/views/widgets/input_email_widget.dart';
import 'package:denguecare_firebase/views/widgets/input_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final String userType = 'Admin';
  final sex = ['Male', 'Female'];
  DropdownMenuItem<String> buildMenuItem(String sex) => DropdownMenuItem(
        value: sex,
        child: Text(sex),
      );

  String? value;
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordNotVisible = true;
  final uuid = const Uuid();
  String uniqueDocId = '';

  @override
  void initState() {
    super.initState();
    generateUniqueId();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    value = 'Male';
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title: Text('Admin Register', style: GoogleFonts.poppins(fontSize: 20)),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const ManageAdmin());
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
            child: Form(
              key: _formKey,
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(
                    maxWidth: 370,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo-no-background.png'),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Text(
                        "ADMIN REGISTRATION",
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      //! First Name and Last Name Widget
                      Row(
                        children: [
                          Expanded(
                            child: InputWidget(
                              hintText: "First Name",
                              controller: _firstnameController,
                              obscureText: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InputWidget(
                              hintText: "Last Name",
                              controller: _lastnameController,
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InputAgeWidget(
                              hintText: "Age",
                              controller: _ageController,
                              obscureText: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    isExpanded: true,
                                    items: sex.map(buildMenuItem).toList(),
                                    value: value,
                                    hint: const Text('Sex'),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        value = val;
                                      });
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InputContactNumber(
                          hintText: "Contact Number (10-digit)",
                          controller: _contactNumberController,
                          obscureText: false),
                      const SizedBox(height: 20),
                      InputEmailWidget(
                        hintText: "Email",
                        controller: _emailController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      InputConfirmPassWidget(
                        hintText: "Password",
                        controller: _passwordController,
                        confirmController: _confirmPasswordController,
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
                          onPressed: () async {
                            try {
                              if (_formKey.currentState!.validate()) {
                                signUp(
                                    _emailController.text.trim(),
                                    _confirmPasswordController.text.trim(),
                                    _firstnameController.text.trim(),
                                    _lastnameController.text.trim(),
                                    _ageController.text.trim(),
                                    value!,
                                    _contactNumberController.text.trim(),
                                    userType);
                              }
                            } catch (e) {
                              _showSnackbarError(context, e.toString());
                              print(e.toString());
                            }
                          },
                          child: Text("Register",
                              style: GoogleFonts.poppins(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void generateUniqueId() {
    setState(() {
      uniqueDocId = uuid.v4(); // Generates a new unique ID
    });
  }

  void signUp(String email, String password, String firstname, String lastname,
      String age, String? sex, String contactnumber, String userType) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFirestore(email, firstname, lastname, age, sex,
                    contactnumber, userType)
              })
          .catchError((e) {
        _showSnackbarError(context, e.message.toString());
      });
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      _showSnackbarError(context, e.message.toString());
    }
  }

  postDetailsToFirestore(String email, String firstname, String lastname,
      String age, String? sex, String contactnumber, String userType) async {
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({
      'email': _emailController.text,
      'document_id': uniqueDocId,
      'user_uid': user.uid,
      'firstName': _firstnameController.text,
      'lastName': _lastnameController.text,
      'age': _ageController.text,
      'sex': sex,
      'contact_number': _contactNumberController.text,
      'role': userType,
    });

    // Get.offAll(() => const ManageAdmin());
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
