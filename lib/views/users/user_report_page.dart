import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/widgets/input_widget_nullable.dart';
import 'package:denguecare_firebase/views/widgets/input_contact_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../widgets/input_address_widget.dart';
import '../widgets/input_age_widget.dart';
import '../widgets/input_widget.dart';

class UserReportPage extends StatefulWidget {
  const UserReportPage({super.key});

  @override
  State<UserReportPage> createState() => _UserReportPageState();
}

class _UserReportPageState extends State<UserReportPage> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Widget _buildProgressIndicator() {
    if (_isSubmitting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(); // Return an empty container if _isSubmitting is false
    }
  }

  final uuid = const Uuid();
  String uniqueDocId = '';
  @override
  void initState() {
    super.initState();
    // Set the default value for the text controller
    purokvalue = 'Select Purok';
    generateUniqueId();
  }

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactnumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool isEnglish = true;

  void toggleLanguage() {
    setState(() {
      isEnglish = !isEnglish;
    });
  }

  bool _headache = false;
  bool _bodymalaise = false;
  bool _myalgia = false;
  bool _arthralgia = false;
  bool _retroOrbitalPain = false;
  bool _anorexia = false;
  bool _nausea = false;
  bool _vomiting = false;
  bool _diarrhea = false;
  bool _flushedSkin = false;
  bool _fever = false;
  bool _lowPlateLet = false;
  String? value;
  String? purokvalue;
  final sex = ['Male', 'Female'];
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        leading: BackButton(
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressIndicator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Report a case",
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      _gap(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Please enter the following details.",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center),
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputWidget(
                              labelText: "First Name",
                              controller: _firstnameController,
                              obscureText: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InputWidgetNullable(
                              labelText: "Middle Name",
                              controller: _middlenameController,
                              obscureText: false,
                            ),
                          )
                        ],
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputWidget(
                              labelText: "Last Name",
                              controller: _lastnameController,
                              obscureText: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InputWidgetNullable(
                              labelText: "Suffix i.e.(Jr., Sr., etc.)",
                              controller: _suffixController,
                              hintText: "Suffix(optional)",
                              obscureText: false,
                            ),
                          )
                        ],
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputAgeWidget(
                              labelText: 'Age',
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
                                  onChanged: (value) =>
                                      setState(() => this.value = value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      //! CONTACT NUMBER
                      InputContactNumber(
                        controller: _contactnumberController,
                        labelText: 'Contact Number (10-digit)',
                        obscureText: false,
                      ),
                      _gap(),
                      InputAddressWidget(
                        labelText: 'Address',
                        controller: _addressController,
                        obscureText: false,
                      ),
                      _gap(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
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
                      _gap(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(isEnglish ? "Symptoms" : 'Sintomas',
                                style: GoogleFonts.poppins(fontSize: 30)),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          InkWell(
                            onTap: toggleLanguage,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: toggleLanguage,
                                  icon: const Icon(Icons.translate_rounded),
                                  splashColor: Colors.green[300],
                                ),
                                // Text(
                                //   'Translate',
                                //   style: GoogleFonts.poppins(fontSize: 12),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                      _gap(),
                      Row(
                        //! row for headache & body malaise
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _headache,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _headache = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Headache' : 'Sakit ng Ulo',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _bodymalaise,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _bodymalaise = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Body Malaise' : 'Sakit ng katawan',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //! row for Myalgia & Arthralgia
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _myalgia,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _myalgia = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Myalgia' : 'Pananakit ng kalamnan',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _arthralgia,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _arthralgia = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Arthralgia' : 'Rayuma',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //! row for retro_orbital_pain & anorexia
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _retroOrbitalPain,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _retroOrbitalPain = value;
                                });
                              },
                              title: Text(
                                isEnglish
                                    ? 'Retro Orbital Pain'
                                    : 'Pananakit sa likod ng mata',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _anorexia,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _anorexia = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Anorexia' : 'Walang ganang kumain',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //! row for nausea & vomiting
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _nausea,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _nausea = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Nausea' : 'Pagkahilo',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _vomiting,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _vomiting = value;
                                });
                              },
                              title: Text(
                                isEnglish ? 'Vomiting' : 'Pagsusuka',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //! row for Diarrhea & Flushed skin and Skin rash
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _diarrhea,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _diarrhea = value;
                                });
                              },
                              title: Text(isEnglish ? 'Diarrhea' : 'Pagtatae',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _flushedSkin,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _flushedSkin = value;
                                });
                              },
                              title: Text(
                                  isEnglish
                                      ? 'Rashes'
                                      : 'Pantal-pantal sa katawan',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        //! row for On and off fever and Low PlateLet Count
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              value: _fever,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _fever = value;
                                });
                              },
                              title: Text(
                                  isEnglish ? 'On and Off Fever' : 'Nilalagnat',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              value: _lowPlateLet,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _lowPlateLet = value;
                                });
                              },
                              title: Text(
                                  isEnglish
                                      ? 'Low platelet count'
                                      : 'Mababang bilang ng platelet',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Submit',
                                style: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                purokvalue != 'Select Purok') {
                              uploadDataToFirebase();
                            } else {
                              _showSnackbarError(
                                  context, "Please complete the form.");
                            }
                          },
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

  void uploadDataToFirebase() async {
    setState(() {
      _isSubmitting = true; // Begin submission
    });
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    int age = int.parse(_ageController.text);
    try {
      CollectionReference reports =
          FirebaseFirestore.instance.collection('reports');

      String? selectedPurok = purokvalue;
      const CircularProgressIndicator();
      LatLng selectedLatLng =
          puroklist[selectedPurok] ?? const LatLng(0.0, 0.0);
      await reports.add({
        'firstName': _firstnameController.text,
        'lastName': _lastnameController.text,
        'middle_name': _middlenameController.text,
        'suffix': _suffixController.text,
        'age': age,
        'sex': value,
        'contact_number': _contactnumberController.text,
        'document_id': uniqueDocId,
        'address': _addressController.text,
        'purok': purokvalue,
        'headache': _headache,
        'body_malaise': _bodymalaise,
        'myalgia': _myalgia,
        'arthralgia': _arthralgia,
        'retroOrbitalPain': _retroOrbitalPain,
        'anorexia': _anorexia,
        'nausea': _nausea,
        'vomiting': _vomiting,
        'diarrhea': _diarrhea,
        'flushedSkin': _flushedSkin,
        'fever': _retroOrbitalPain,
        'lowPlateLet': _lowPlateLet,
        'date': FieldValue.serverTimestamp(),
        'emailid': user!.email!,
        'status': 'Suspected',
        'first_symptom_date': '',
        'other_hospital': 'No',
        'patient_admitted': 'No',
        'hospital_name': ' ',
        'patient_recovered': 'No',
        'checked': 'No',
        'longitude': selectedLatLng.longitude,
        'latitude': selectedLatLng.latitude,

        // Add other fields as necessary
      });
      Get.back();
    } catch (e) {
      _showSnackbarError(context, e.toString());
    } finally {
      _isSubmitting = false;
      resetForm();
      _showSnackbarSuccess(context, "SUCCESS");
    }
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

  void resetForm() {
    setState(() {
      _firstnameController.clear();
      _lastnameController.clear();
      _ageController.clear();
      _addressController.clear();
      _middlenameController.clear();
      _suffixController.clear();
      _contactnumberController.clear();
      purokvalue = 'Select Purok';
      value = 'Male';
      _headache = false;
      _bodymalaise = false;
      _myalgia = false;
      _arthralgia = false;
      _retroOrbitalPain = false;
      _anorexia = false;
      _nausea = false;
      _vomiting = false;
      _diarrhea = false;
      _flushedSkin = false;
      _fever = false;
      _lowPlateLet = false;
    });
  }
}

Widget _gap() => const SizedBox(height: 16);
DropdownMenuItem<String> buildMenuItem(String sex) => DropdownMenuItem(
      value: sex,
      child: Text(sex),
    );

void handleClick(int item) {
  switch (item) {
    case 0:
      break;
    case 1:
      break;
    case 2:
      break;
  }
}
