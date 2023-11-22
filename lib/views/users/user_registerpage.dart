import 'package:denguecare_firebase/views/users/user_homepage.dart';
import 'package:denguecare_firebase/views/widgets/input_contact_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../login_page.dart';
import '../widgets/input_age_widget.dart';
import '../widgets/input_confirmpass_widget.dart';
import '../widgets/input_email_widget.dart';
import '../widgets/input_widget.dart';
import 'dart:async';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final _auth = FirebaseAuth.instance;

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final puroklist = <String, LatLng>{
    'Select Purok': const LatLng(0.0, 0.0),
    'Bread Village': const LatLng(7.114766536403886, 125.60696940052657),
    'Carnation St.': const LatLng(7.10508641333724, 125.61515746758455),
    'Hillside Sibdivision': const LatLng(7.108102285076556, 125.62406250246629),
    'Ladislawa Village': const LatLng(7.098200119201119, 125.61019426301475),
    'NCCC Village': const LatLng(7.096960557359798, 125.61275624974145),
    'NHA Buhangin': const LatLng(7.113905613264349, 125.62504342908515),
    'Purok Anahaw': const LatLng(7.109096059265925, 125.61964421925765),
    'Purok Apollo': const LatLng(7.107768956186394, 125.61416454760068),
    'Purok Bagong Lipunan': const LatLng(7.095857531140644, 125.61095333058628),
    'Purok Balite 1 and 2': const LatLng(7.119549280388477, 125.60805092125558),
    'Purok Birsaba': const LatLng(7.105061321316023, 125.61969713317032),
    // 'Purok Blk. 2': const LatLng(7.114766536403886, 125.60696940052657),
    'Purok Blk. 10': const LatLng(7.108181645444775, 125.62655502248933),
    'Purok Buhangin Hills': const LatLng(7.117113700249076, 125.60809919264209),
    'Purok Cubcub': const LatLng(7.116119305511145, 125.6141471539433),
    'Purok Damayan': const LatLng(7.116054904638758, 125.61541329783626),
    'Purok Dumanlas Proper':
        const LatLng(7.106273586217053, 125.62089114209782),
    'Purok Engan Village': const LatLng(7.118753809802358, 125.60452647717479),
    'Purok Kalayaan': const LatLng(7.1032977897030545, 125.62238184200663),
    'Purok Lopzcom': const LatLng(7.105594927870564, 125.60341410176332),
    'Purok Lourdes': const LatLng(7.105715353615316, 125.62532253389722),
    'Purok Lower St Jude': const LatLng(7.114410259476265, 125.61541606253824),
    'Purok Maglana': const LatLng(7.104095409160874, 125.6102089025267),
    'Purok Mahayag': const LatLng(7.111363688338518, 125.62058462285405),
    'Purok Margarita': const LatLng(7.108554977313653, 125.62107532100138),
    'Purok Medalla Melagrosa':
        const LatLng(7.112585632970439, 125.61933725203026),
    'Purok Molave': const LatLng(7.1102453162628745, 125.61514560550482),
    'Purok Mt. Carmel': const LatLng(7.107832093153038, 125.62042899888917),
    'Purok New San Isidro': const LatLng(7.114646894156096, 125.62149873266685),
    'Purok NIC': const LatLng(7.1056606477663, 125.61569942888742),
    'Purok Old San Isidro': const LatLng(7.113866298326243, 125.62157743217746),
    'Purok Orchids': const LatLng(7.113904106560612, 125.61480764168593),
    'Purok Palm Drive': const LatLng(7.099059763574843, 125.61713711812722),
    'Purok Panorama Village':
        const LatLng(7.1120899631907895, 125.60397931051439),
    'Purok Pioneer Village':
        const LatLng(7.112689498658063, 125.60951878984032),
    'Purok Purok Pine Tree':
        const LatLng(7.112869971081789, 125.61574491979016),
    'Purok Sampaguita': const LatLng(7.106326631239756, 125.61449205861119),
    'Purok San Antonio': const LatLng(7.113792622959072, 125.6226665585437),
    'Purok Sandawa': const LatLng(7.104890601658813, 125.60990281312078),
    'Purok San Jose': const LatLng(7.116417507324833, 125.6194716967905),
    'Purok San Lorenzo': const LatLng(7.1142672, 125.6176972),
    'Purok San Miguel Lower and Upper':
        const LatLng(7.102392757056179, 125.61924295918227),
    'Purok San Nicolas': const LatLng(7.11144062162212, 125.61787758846674),
    'Purok San Pedro Village':
        const LatLng(7.099771300160193, 125.61313186589621),
    'Purok San Vicente': const LatLng(7.110561784251983, 125.62277836600413),
    'Purok Spring Valley 1 and 2':
        const LatLng(7.103488383914926, 125.60890080560779),
    'Purok Sta. Cruz': const LatLng(7.113860769421073, 125.62500720591544),
    'Purok Sta. Maria': const LatLng(7.103812074866343, 125.62119095608588),
    'Purok Sta. Teresita': const LatLng(7.110141276760571, 125.61893022718402),
    'Purok Sto. Niño': const LatLng(7.107110521047068, 125.61729906299115),
    'Purok Sto. Rosario': const LatLng(7.100879717554058, 125.61703643376391),
    'Purok Sunflower': const LatLng(7.101395920309526, 125.61513843282769),
    'Purok Talisay': const LatLng(7.110000319864266, 125.62038233087334),
    'Purok Upper St. Jude': const LatLng(7.114751305745676, 125.6171331261847),
    'Purok Waling-waling': const LatLng(7.110545022083019, 125.6174721171983),
    'Purok Watusi': const LatLng(7.102191824458489, 125.61687297676335),
  };
  final sex = ['Male', 'Female'];
  String? value;
  String? purokvalue;
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordNotVisible = true;
  final _formKey = GlobalKey<FormState>();
  final String userType = 'User';
  var _verificationId = ''.obs;
//late int _remainingTime = 60;

  int _counter = 0;
  late Timer _timer;
  late StreamController<int> _events;
  DropdownMenuItem<String> buildMenuItem(String sex) => DropdownMenuItem(
        value: sex,
        child: Text(sex),
      );

  @override
  initState() {
    super.initState();
    _events = StreamController<int>.broadcast();
    _events.add(60);
    purokvalue = 'Select Purok';
  }

  void _startTimer() {
    _counter = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //setState(() {
      (_counter > 0) ? _counter-- : _timer.cancel();
      //});
      print('This is counter $_counter');
      _events.add(_counter);
    });
  }

  var _otpCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _firstnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    value = 'Male';
    purokvalue = 'Select Purok';
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 118, 162, 120),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 370),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo-no-background.png'),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        Text(
                          "USER REGISTRATION",
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
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
                                    items: sex.map(buildMenuItem).toList(),
                                    value: value,
                                    hint: const Text('Sex'),
                                    onChanged: (value) =>
                                        setState(() => this.value = value),
                                  ),
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
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    padding: const EdgeInsets.all(0),
                                    isExpanded: true,
                                    items: puroklist.keys.map((String purok) {
                                      return DropdownMenuItem<String>(
                                        value: purok,
                                        child: Text(purok),
                                      );
                                    }).toList(),
                                    value: purokvalue,
                                    onChanged: (val) =>
                                        setState(() => purokvalue = val),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                  String num =
                                      "+63${_contactNumberController.text}";
                                  _startTimer();
                                  _showOTPDialog(context);
                                  verifyPhone(num);
                                }
                              } on FirebaseAuthException catch (e) {
                                _showSnackbarError(
                                    context, e.message.toString());
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
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.blue),
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
      ),
    );
  }

  void _showOTPDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _cardOTPDialog(context);
        });
  }

  Widget _cardOTPDialog(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Verify your phone number',
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: StreamBuilder<int>(
        stream: _events.stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          //print('The snapshot data: ${snapshot.data.toString()}');
          return Card(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 370),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Verify your phone number',
                        style: GoogleFonts.poppins(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'A 6-digit OTP code is sent to your phone',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      OTPTextField(
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        style: GoogleFonts.poppins(fontSize: 18),
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldStyle: FieldStyle.underline,
                        inputFormatter: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onCompleted: (pin) {
                          _otpCode = pin;
                          //print(_otpCode);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Time Left: ${snapshot.data.toString()}',
                        //style: GoogleFonts.poppins(fontSize: 12),
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
                            // if (_otpCode.isNotEmpty) {
                            // } else {
                            //   Utils.showSnackBar("Please enter the OTP code.");
                            // }
                            try {
                              PhoneAuthCredential credential =
                                  PhoneAuthProvider.credential(
                                verificationId: _verificationId.value,
                                smsCode: _otpCode,
                              );

                              await _auth.signInWithCredential(credential);
                              signUp(
                                  _emailController.text.trim(),
                                  _confirmPasswordController.text.trim(),
                                  _firstnameController.text.trim(),
                                  _lastnameController.text.trim(),
                                  _ageController.text.trim(),
                                  value?.trim(),
                                  _contactNumberController.text.trim(),
                                  purokvalue?.trim(),
                                  userType);

                              _showSnackbarSuccess(context, 'Success');

                              // Handle user registration completion
                            } on FirebaseAuthException catch (e) {
                              _showSnackbarError(context, e.message.toString());
                            }
                          },
                          child: Text("Confirm",
                              style: GoogleFonts.poppins(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _timer.cancel();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
//! SHOWDIALOG POP UP

//! SIGN UP
  void signUp(
      String email,
      String password,
      String firstname,
      String lastname,
      String age,
      String? sex,
      String contactnumber,
      String? purok,
      String userType) async {
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
                postDetailsToFirestore(email, firstname, lastname, age, sex!,
                    contactnumber, purok, userType)
              })
          .catchError((e) {
        return _showSnackbarError(context, e.message.toString());
      });
    } on FirebaseAuthException catch (e) {
      //print(e);
      _showSnackbarError(context, e.message.toString());
    }
  }

  postDetailsToFirestore(
      String email,
      String firstname,
      String lastname,
      String age,
      String sex,
      String contactnumber,
      String? purok,
      String userType) async {
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({
      'email': _emailController.text,
      'firstname': _firstnameController.text,
      'lastname': _lastnameController.text,
      'age': _ageController.text,
      'sex': value,
      'contact_number': _contactNumberController.text,
      'purok': purokvalue,
      'role': userType
    });

    Get.offAll(() => const UserMainPage());
  }

  Future<void> verifyPhone(String phoneNumber) async {
    verificationCompleted(PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);

      // Handle user registration completion
    }

    verificationFailed(FirebaseAuthException e) {
      // Handle verification failure

      _showSnackbarError(context, e.message.toString());
    }

    codeSent(String verificationId, [int? resendToken]) async {
      // Store the verification ID
      _verificationId = verificationId.obs;
    }

    codeAutoRetrievalTimeout(String verificationId) {
      // Auto retrieval timeout, handle it if needed
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
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
