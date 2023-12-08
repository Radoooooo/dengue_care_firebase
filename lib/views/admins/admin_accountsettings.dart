import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:denguecare_firebase/views/widgets/input_age_widget.dart';
import 'package:denguecare_firebase/views/widgets/input_email_widget.dart';
import 'package:denguecare_firebase/views/widgets/input_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAccountSettings extends StatefulWidget {
  const AdminAccountSettings({super.key});

  @override
  State<AdminAccountSettings> createState() => _AdminAccountSettingsState();
}

class _AdminAccountSettingsState extends State<AdminAccountSettings> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 118, 162, 120),
      appBar: AppBar(
        title:
            Text("Account Settings", style: GoogleFonts.poppins(fontSize: 20)),
        leading: BackButton(
          onPressed: () {
            Get.offAll(() => const AdminMainPage());
          },
        ),
      ),
      body: const AdminEdit(),
    );
  }
}

class AdminEdit extends StatefulWidget {
  const AdminEdit({super.key});

  @override
  State<AdminEdit> createState() => _AdminEditState();
}

class _AdminEditState extends State<AdminEdit> {
  final FirebaseAuth aw = FirebaseAuth.instance;
  final TextEditingController _newnameController = TextEditingController();
  final TextEditingController _newfirstnameController = TextEditingController();
  final TextEditingController _newlastnameController = TextEditingController();
  final TextEditingController _newageController = TextEditingController();
  final TextEditingController _newemailController = TextEditingController();
  final puroklist = <String>{
    'Select Purok',
    'Bread Village',
    'Carnation St.',
    'Hillside Sibdivision',
    'Ladislawa Village',
    'NCCC Village',
    'NHA Buhangin',
    'Purok Anahaw',
    'Purok Apollo',
    'Purok Bagong Lipunan',
    'Purok Balite 1 and 2',
    'Purok Birsaba',
    'Purok Blk. 10',
    'Purok Buhangin Hills',
    'Purok Cubcub',
    'Purok Damayan',
    'Purok Dumanlas Proper',
    'Purok Engan Village',
    'Purok Kalayaan',
    'Purok Lopzcom',
    'Purok Lourdes',
    'Purok Lower St Jude',
    'Purok Maglana',
    'Purok Mahayag',
    'Purok Margarita',
    'Purok Medalla Melagrosa',
    'Purok Molave',
    'Purok Mt. Carmel',
    'Purok New San Isidro',
    'Purok NIC',
    'Purok Old San Isidro',
    'Purok Orchids',
    'Purok Palm Drive',
    'Purok Panorama Village',
    'Purok Pioneer Village',
    'Purok Purok Pine Tree',
    'Purok Sampaguita',
    'Purok San Antonio',
    'Purok Sandawa',
    'Purok San Jose',
    'Purok San Lorenzo',
    'Purok San Miguel Lower and Upper',
    'Purok San Nicolas',
    'Purok San Pedro Village',
    'Purok San Vicente',
    'Purok Spring Valley 1 and 2',
    'Purok Sta. Cruz',
    'Purok Sta. Maria',
    'Purok Sta. Teresita',
    'Purok Sto. Niño',
    'Purok Sto. Rosario',
    'Purok Sunflower',
    'Purok Talisay',
    'Purok Upper St. Jude',
    'Purok Waling-waling',
    'Purok Watusi',
  };
  String? _selectedPurok;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          // Update _selectedPurok if the 'purok' key exists in userData
          _selectedPurok = userData['purok'] ?? _selectedPurok;
        });
      }
    });
  }

  @override
  void dispose() {
    _newnameController.dispose();
    _newfirstnameController.dispose();
    _newlastnameController.dispose();
    _newageController.dispose();
    _newemailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(); // Loading indicator
        }
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        _newnameController.text = userData['name'] ?? '';
        _newfirstnameController.text = userData['firstName'] ?? '';
        _newlastnameController.text = userData['lastName'] ?? '';
        _newageController.text = userData['age'] ?? '';
        _newemailController.text = userData['email'] ?? '';
        return SingleChildScrollView(
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
                    maxWidth: 370,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo-no-background.png'),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Text(
                        "EDIT USER INFO",
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InputWidget(
                              labelText: 'First Name',
                              controller: _newfirstnameController,
                              obscureText: false,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: InputWidget(
                              labelText: "Last Name",
                              controller: _newlastnameController,
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InputAgeWidget(
                        labelText: "Age",
                        controller: _newageController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      InputEmailWidget(
                        labelText: "Email",
                        controller: _newemailController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedPurok ?? userData['purok'],
                        items: puroklist.map((purok) {
                          return DropdownMenuItem(
                            value: purok,
                            child: Text(purok),
                          );
                        }).toList(),
                        onChanged: (val) {
                          print(val);
                          setState(() {
                            _selectedPurok = val;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Purok',
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
                            _updateUserInfo();
                          },
                          child: Text(
                            'Update',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUserInfoinFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    String newName =
        '${_newfirstnameController.text} ${_newlastnameController.text}';

    String newfirstName = _newfirstnameController.text;
    String newlastName = _newlastnameController.text;
    String newAge = _newageController.text;
    String newEmail = _newemailController.text;
    try {
      await user!.updateDisplayName(newName);
      await user.updateEmail(newEmail);
      // _updateUserInfoinFirestore(user.uid, newfirstName, newlastName, newAge,
      //     newEmail, _selectedPurok!);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': newfirstName,
        'lastName': newlastName,
        'name': newName,
        'age': newAge,
        'email': newEmail,
        'purok': _selectedPurok!,
      });
      await user.reload();
      logAdminAction('Edit Account Settings', user.uid);
      // ignore: use_build_context_synchronously
      _showSnackbarSuccess(context, "User Information updated successfully");
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showSnackbarError(context, error.toString());
    }
  }

  Future<void> _updateUserInfo() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('Do you wish to proceed with the update?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _updateUserInfoinFirestore();
                Navigator.of(context).pop(); // Return true if user confirms
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return false if user cancels
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbarSuccess(BuildContext context, String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _showSnackbarError(BuildContext context, String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
