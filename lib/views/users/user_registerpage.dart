import 'package:denguecare_firebase/views/admins/admin_register.dart';
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

class _UserRegisterPageState extends State<UserRegisterPage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  late TabController _tabController;
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
  bool _isEulaAccepted = false;
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
    _tabController = TabController(length: 2, vsync: this);
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
      // ignore: avoid_print
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 118, 162, 120),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 570),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black87,
                      labelStyle: GoogleFonts.poppins(fontSize: 18),
                      tabs: const [
                        Tab(text: 'User Registration'),
                        Tab(text: 'Admin Registration'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 370,
                      height: 800, // Adjust the height as needed
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUserRegistrationTab(),
                          // _buildAdminRegistrationTab(),
                          const AdminRegisterPage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserRegistrationTab() {
    return Form(
      key: _formKey,
      child: Card(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 270),
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
                          String num = "+63${_contactNumberController.text}";
                          _startTimer();
                          _showOTPDialog(context);
                          verifyPhone(num);
                        } else if (!_isEulaAccepted) {
                          _showSnackbarError(
                              context, 'Please accept the EULA.');
                        }
                      } on FirebaseAuthException catch (e) {
                        _showSnackbarError(context, e.message.toString());
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

PERSONAL INFORMATION COLLECTION
-------------------------------
When you create an account, or otherwise provide us with your personal 
information through the website (www.denguecare.online) or through our 
application DengueCare, the personal information we collect may include your:
- Name 
- Address 
- Email Address 
- Contact Number 
- Mobile Number 
- Date of Birth 
- Gender

You must only submit to us, our authorized agent or the website, information
which is accurate and not misleading and you must keep it up to date and inform
us of changes (more information below). We reserve the right to request
for documentation to verify the information provided by you.

We will only be able to collect your personal information if you voluntarily submit
the information to us. If you choose not to submit your personal information to us or
subsequently withdraw your consent to our use of your personal information,
we may not be able to provide you with our Services. You may access and update 
your personal information submitted to us at any time as described below.

If you provide personal information of any third party to us, we assume that
you have obtained the required consent from the relevant third party to share 
and transfer his/her personal information to us.

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

                              // ignore: use_build_context_synchronously
                              _showSnackbarSuccess(context, 'Success');

                              // Handle user registration completion
                            } on FirebaseAuthException catch (e) {
                              // ignore: use_build_context_synchronously
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
      'role': userType,
      'approved': true,
      'isVerified': false,
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
