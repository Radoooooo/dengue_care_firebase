import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_manageadmin.dart';
import 'package:denguecare_firebase/views/login_page.dart';
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
  bool _isEulaAccepted = false;

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
    return Form(
      key: _formKey,
      child: Card(
        child: SingleChildScrollView(
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
                //!! EULA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isEulaAccepted,
                      onChanged: (value) {
                        setState(() {
                          _isEulaAccepted = value!;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        _showEulaDialog(context);
                      },
                      child: Text(
                        'I have read and accepted the EULA',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
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
                        if (_formKey.currentState!.validate() &&
                            _isEulaAccepted) {
                          signUp(
                              _emailController.text.trim(),
                              _confirmPasswordController.text.trim(),
                              _firstnameController.text.trim(),
                              _lastnameController.text.trim(),
                              _ageController.text.trim(),
                              value!,
                              _contactNumberController.text.trim(),
                              userType);
                        } else if (!_isEulaAccepted) {
                          _showSnackbarError(
                              context, 'Please accept the EULA.');
                        }
                        _showSnackbarSuccess(
                            context, 'Please wait for superadmin approval.');
                      } catch (e) {
                        _showSnackbarError(context, e.toString());
                        print(e.toString());
                      }
                    },
                    child: Text("Register",
                        style: GoogleFonts.poppins(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    Get.to(() => const LoginPage());
                  },
                  child: Text(
                    "Already have an accont? Sign in!",
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
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

  void _showEulaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'End User License Agreement',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              // Add your EULA statement here
              ''' End-User License Agreement ("Agreement")  
=

Last updated: January 16, 2024

Please read this End-User License Agreement carefully before clicking the "I
Agree" button, downloading or using DengueCare.

Interpretation and Definitions  
------------------------------

Interpretation  
**************

The words of which the initial letter is capitalized have meanings defined
under the following conditions. The following definitions shall have the same
meaning regardless of whether they appear in singular or in plural.

Definitions  
***********

For the purposes of this End-User License Agreement:

  * Agreement means this End-User License Agreement that forms the entire
    agreement between You and the Company regarding the use of the
    Application. This Agreement has been created with the help of the [Free
    EULA Generator](https://www.freeprivacypolicy.com/free-eula-generator/).

  * Application means the software program provided by the Company downloaded
    by You to a Device, named DengueCare

  * Company (referred to as either "the Company", "We", "Us" or "Our" in this
    Agreement) refers to DengueCare.

  * Content refers to content such as text, images, or other information that
    can be posted, uploaded, linked to or otherwise made available by You,
    regardless of the form of that content.

  * Country refers to: Philippines

  * Device means any device that can access the Application such as a
    computer, a cellphone or a digital tablet.

  * Third-Party Services means any services or content (including data,
    information, applications and other products services) provided by a
    third-party that may be displayed, included or made available by the
    Application.

  * You means the individual accessing or using the Application or the
    company, or other legal entity on behalf of which such individual is
    accessing or using the Application, as applicable.


Acknowledgment  
--------------

By clicking the "I Agree" button, downloading or using the Application, You
are agreeing to be bound by the terms and conditions of this Agreement. If You
do not agree to the terms of this Agreement, do not click on the "I Agree"
button, do not download or do not use the Application.

This Agreement is a legal document between You and the Company and it governs
your use of the Application made available to You by the Company.

The Application is licensed, not sold, to You by the Company for use strictly
in accordance with the terms of this Agreement.

License  
-------

Scope of License  
****************

The Company grants You a revocable, non-exclusive, non-transferable, limited
license to download, install and use the Application strictly in accordance
with the terms of this Agreement.

The license that is granted to You by the Company is solely for your personal,
non-commercial purposes strictly in accordance with the terms of this
Agreement.

Third-Party Services  
--------------------

The Application may display, include or make available third-party content
(including data, information, applications and other products services) or
provide links to third-party websites or services.

You acknowledge and agree that the Company shall not be responsible for any
Third-party Services, including their accuracy, completeness, timeliness,
validity, copyright compliance, legality, decency, quality or any other aspect
thereof. The Company does not assume and shall not have any liability or
responsibility to You or any other person or entity for any Third-party
Services.

You must comply with applicable Third parties' Terms of agreement when using
the Application. Third-party Services and links thereto are provided solely as
a convenience to You and You access and use them entirely at your own risk and
subject to such third parties' Terms and conditions.

Term and Termination  
--------------------

This Agreement shall remain in effect until terminated by You or the Company.
The Company may, in its sole discretion, at any time and for any or no reason,
suspend or terminate this Agreement with or without prior notice.

This Agreement will terminate immediately, without prior notice from the
Company, in the event that you fail to comply with any provision of this
Agreement. You may also terminate this Agreement by deleting the Application
and all copies thereof from your Device or from your computer.

Upon termination of this Agreement, You shall cease all use of the Application
and delete all copies of the Application from your Device.

Termination of this Agreement will not limit any of the Company's rights or
remedies at law or in equity in case of breach by You (during the term of this
Agreement) of any of your obligations under the present Agreement.

Indemnification  
---------------

You agree to indemnify and hold the Company and its parents, subsidiaries,
affiliates, officers, employees, agents, partners and licensors (if any)
harmless from any claim or demand, including reasonable attorneys' fees, due
to or arising out of your: (a) use of the Application; (b) violation of this
Agreement or any law or regulation; or (c) violation of any right of a third
party.

No Warranties  
-------------

The Application is provided to You "AS IS" and "AS AVAILABLE" and with all
faults and defects without warranty of any kind. To the maximum extent
permitted under applicable law, the Company, on its own behalf and on behalf
of its affiliates and its and their respective licensors and service
providers, expressly disclaims all warranties, whether express, implied,
statutory or otherwise, with respect to the Application, including all implied
warranties of merchantability, fitness for a particular purpose, title and
non-infringement, and warranties that may arise out of course of dealing,
course of performance, usage or trade practice. Without limitation to the
foregoing, the Company provides no warranty or undertaking, and makes no
representation of any kind that the Application will meet your requirements,
achieve any intended results, be compatible or work with any other software,
applications, systems or services, operate without interruption, meet any
performance or reliability standards or be error free or that any errors or
defects can or will be corrected.

Without limiting the foregoing, neither the Company nor any of the company's
provider makes any representation or warranty of any kind, express or implied:
(i) as to the operation or availability of the Application, or the
information, content, and materials or products included thereon; (ii) that
the Application will be uninterrupted or error-free; (iii) as to the accuracy,
reliability, or currency of any information or content provided through the
Application; or (iv) that the Application, its servers, the content, or
e-mails sent from or on behalf of the Company are free of viruses, scripts,
trojan horses, worms, malware, timebombs or other harmful components.

Some jurisdictions do not allow the exclusion of certain types of warranties
or limitations on applicable statutory rights of a consumer, so some or all of
the above exclusions and limitations may not apply to You. But in such a case
the exclusions and limitations set forth in this section shall be applied to
the greatest extent enforceable under applicable law. To the extent any
warranty exists under law that cannot be disclaimed, the Company shall be
solely responsible for such warranty.

Limitation of Liability  
-----------------------

Notwithstanding any damages that You might incur, the entire liability of the
Company and any of its suppliers under any provision of this Agreement and
your exclusive remedy for all of the foregoing shall be limited to the amount
actually paid by You for the Application or through the Application or 100 USD
if You haven't purchased anything through the Application.

To the maximum extent permitted by applicable law, in no event shall the
Company or its suppliers be liable for any special, incidental, indirect, or
consequential damages whatsoever (including, but not limited to, damages for
loss of profits, loss of data or other information, for business interruption,
for personal injury, loss of privacy arising out of or in any way related to
the use of or inability to use the Application, third-party software and/or
third-party hardware used with the Application, or otherwise in connection
with any provision of this Agreement), even if the Company or any supplier has
been advised of the possibility of such damages and even if the remedy fails
of its essential purpose.

Some states/jurisdictions do not allow the exclusion or limitation of
incidental or consequential damages, so the above limitation or exclusion may
not apply to You.

Severability and Waiver  
-----------------------

Severability  
************

If any provision of this Agreement is held to be unenforceable or invalid,
such provision will be changed and interpreted to accomplish the objectives of
such provision to the greatest extent possible under applicable law and the
remaining provisions will continue in full force and effect.

Waiver  
******

Except as provided herein, the failure to exercise a right or to require
performance of an obligation under this Agreement shall not affect a party's
ability to exercise such right or require such performance at any time
thereafter nor shall the waiver of a breach constitute a waiver of any
subsequent breach.

Product Claims  
--------------

The Company does not make any warranties concerning the Application.

United States Legal Compliance  
------------------------------

You represent and warrant that (i) You are not located in a country that is
subject to the United States government embargo, or that has been designated
by the United States government as a "terrorist supporting" country, and (ii)
You are not listed on any United States government list of prohibited or
restricted parties.

Changes to this Agreement  
-------------------------

The Company reserves the right, at its sole discretion, to modify or replace
this Agreement at any time. If a revision is material we will provide at least
30 days' notice prior to any new terms taking effect. What constitutes a
material change will be determined at the sole discretion of the Company.

By continuing to access or use the Application after any revisions become
effective, You agree to be bound by the revised terms. If You do not agree to
the new terms, You are no longer authorized to use the Application.

Governing Law  
-------------

The laws of the Country, excluding its conflicts of law rules, shall govern
this Agreement and your use of the Application. Your use of the Application
may also be subject to other local, state, national, or international laws.

Entire Agreement  
----------------

The Agreement constitutes the entire agreement between You and the Company
regarding your use of the Application and supersedes all prior and
contemporaneous written or oral agreements between You and the Company.

You may be subject to additional terms and conditions that apply when You use
or purchase other Company's services, which the Company will provide to You at
the time of such use or purchase.

Contact Us  
----------

If you have any questions about this Agreement, You can contact Us:

  * By email: b.despi.484014@umindanao.edu.ph

''',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // void signUp(String email, String password, String firstname, String lastname,
  //     String age, String? sex, String contactnumber, String userType) async {
  //   try {
  //     showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => const Center(
  //               child: CircularProgressIndicator(),
  //             ));
  //     await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password)
  //         .then((value) => {
  //               postDetailsToFirestore(email, firstname, lastname, age, sex,
  //                   contactnumber, userType)
  //             })
  //         .catchError((e) {
  //       _showSnackbarError(context, e.message.toString());
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     print(e.message.toString());
  //     _showSnackbarError(context, e.message.toString());
  //   }
  // }
  void signUp(String email, String password, String firstname, String lastname,
      String age, String? sex, String contactnumber, String userType) async {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));

      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user's UID from the authentication result
      String userUid = userCredential.user!.uid;

      // Post user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userUid).set({
        'email': email,
        'document_id': uniqueDocId,
        'user_uid': userUid,
        'firstName': firstname,
        'lastName': lastname,
        'age': age,
        'sex': sex,
        'contact_number': contactnumber,
        'role': userType,
        'approved': false,
        'isVerified': false,
      }, SetOptions(merge: true));

      // Sign out the user to clear the authentication state
      await FirebaseAuth.instance.signOut();

      // Provide feedback to the user (e.g., show a success message).
      _showSnackbarSuccess(context, "Registration successful");

      // Navigate to the login screen or any other screen as needed.
      Get.offAll(() => const LoginPage());
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
      'approved': false,
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
