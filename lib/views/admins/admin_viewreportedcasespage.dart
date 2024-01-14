import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/input_address_widget.dart';
import '../widgets/input_age_widget.dart';
import '../widgets/input_contact_number.dart';
import '../widgets/input_widget.dart';

class AdminViewReportedCasesPage extends StatefulWidget {
  final Map<String, dynamic> reportedCaseData;
  const AdminViewReportedCasesPage({super.key, required this.reportedCaseData});

  @override
  State<AdminViewReportedCasesPage> createState() =>
      _AdminViewReportedCasesPageState();
}

class _AdminViewReportedCasesPageState
    extends State<AdminViewReportedCasesPage> {
  bool _isSubmitting = false;
  Widget _buildProgressIndicator() {
    if (_isSubmitting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(); // Return an empty container if _isSubmitting is false
    }
  }

  final TextEditingController _otherHospitalController =
      TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  String? valueHospital;
  final hospitalList = [
    'Select Hospital',
    'Souhtern Philippines Medical Center',
    'Metro Davao Medical And Research Center',
    'Davao Doctors Hospital',
    'Brokenshire Memorial Hospital',
    'Davao Medical School Foundation Hospital',
    'San Pedro Hospital',
    'Adventist Hospital Davao',
    'Other'
  ];
  String? value;
  final sex = ['Male', 'Female'];
  String? valueStatus;
  final status = ['Suspected', 'Probable', 'Confirmed', 'Recovered'];
  String? valueAdmitted;
  final admitted = ["Yes", "No"];
  String? valueRecovered;
  final recovered = ["Yes", "No"];
  String? purokvalue;
  final puroklist = <String>[
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
    'Purok Blk. 2',
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
    'PurokSan Lorenzo',
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
    'Purok Watusi'
  ];

  DateTime selectedDateofSymptoms = DateTime.now();
  String formattedDateOnly = '';

  @override
  void initState() {
    super.initState();
    // Set the default value for the text controller
    //_hospitalnameController.text = widget.reportedCaseData['hospital_name'];
    valueRecovered = widget.reportedCaseData['patient_recovered'];
    valueAdmitted = widget.reportedCaseData['patient_admitted'];
    valueStatus = widget.reportedCaseData['status'];
    if (hospitalList.contains(widget.reportedCaseData['hospital_name'])) {
      // If 'hospital_name' is in the list, use it
      valueHospital = widget.reportedCaseData['hospital_name'];
    } else if (widget.reportedCaseData['other_hospital'] == 'Yes') {
      // If 'hospital_name' is not in the list and 'other_hospital' is 'yes', use 'Other'
      valueHospital = 'Other';
    } else {
      // Otherwise, set a default value or handle it according to your needs
      valueHospital = hospitalList[0];
    }
    _otherHospitalController.text = widget.reportedCaseData['hospital_name'];
    _contactNumberController.text =
        '0${widget.reportedCaseData['contact_number']}';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _contactNumberController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Case Details'),
          leading: BackButton(
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressIndicator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Reported Case",
                            style: GoogleFonts.poppins(fontSize: 28)),
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputWidget(
                              labelText: "First Name",
                              initialVal: widget.reportedCaseData['firstName'],
                              obscureText: false,
                              enableTextInput: false,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InputWidget(
                              labelText: "Last Name",
                              initialVal: widget.reportedCaseData['lastName'],
                              obscureText: false,
                              enableTextInput: false,
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputAgeWidget(
                              labelText: "Age",
                              hintText: "Age",
                              obscureText: false,
                              enableTextInput: false,
                              initialVal: widget.reportedCaseData['age'],
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
                                  value: widget.reportedCaseData['sex'],
                                  hint: const Text('Sex'),
                                  onChanged: null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      //! CONTACT NUMBER
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          InputContactNumber(
                            labelText: 'Contact Number',
                            hintText: "Contact Number (10-digit)",
                            initialVal:
                                widget.reportedCaseData['contact_number'],
                            enableTextInput: false,
                            obscureText: false,
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy),
                            onPressed: () {
                              _copyToClipboard();
                            },
                          ),
                        ],
                      ),
                      _gap(),
                      InputAddressWidget(
                        labelText: 'Address',
                        initialVal: widget.reportedCaseData['address'],
                        obscureText: false,
                        enableTextInput: false,
                      ),
                      _gap(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            padding: const EdgeInsets.all(0),
                            isExpanded: true,
                            items: puroklist.map(buildMenuItem).toList(),
                            value: widget.reportedCaseData['purok'],
                            hint: const Text('Purok'),
                            onChanged: null,
                          ),
                        ),
                      ),
                      _gap(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Symptoms",
                          style: GoogleFonts.poppins(fontSize: 28),
                        ),
                      ),
                      _gap(),
                      Row(
                        //! row for headache & body malaise
                        children: <Widget>[
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['headache'],
                              onChanged: (value) {},
                              title: const Text('Headache'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['body_malaise'],
                              onChanged: (value) {},
                              title: const Text('Body Malaise'),
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
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['myalgia'],
                              onChanged: (value) {},
                              title: const Text('Myalgia'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['arthralgia'],
                              onChanged: (value) {},
                              title: const Text('Arthralgia'),
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
                              tristate: true,
                              enabled: false,
                              value:
                                  widget.reportedCaseData['retroOrbitalPain'],
                              onChanged: (value) {},
                              title: const Text('Retro Orbital Pain'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['anorexia'],
                              onChanged: (value) {},
                              title: const Text('Anorexia'),
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
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['nausea'],
                              onChanged: (value) {},
                              title: const Text('Nausea'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['vomiting'],
                              onChanged: (value) {},
                              title: const Text('Vomiting'),
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
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['diarrhea'],
                              onChanged: (value) {},
                              title: const Text('Diarrhea'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['flushedSkin'],
                              onChanged: (value) {},
                              title: const Text('Rashes'),
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
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['fever'],
                              onChanged: (value) {},
                              title: const Text('On and Off Fever'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              tristate: true,
                              enabled: false,
                              value: widget.reportedCaseData['lowPlateLet'],
                              onChanged: (value) {},
                              title: const Text('Low platelet count'),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                              contentPadding: const EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                      //! For Updates
                      _gap(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Status : ",
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                items: status.map(buildMenuItemStatus).toList(),
                                value: valueStatus ??
                                    widget.reportedCaseData['status'],
                                hint: Text(widget.reportedCaseData['status'] ??
                                    valueStatus),
                                onChanged: (newvalue) {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  logAdminAction(
                                      'Edit Report - Status', user!.uid);
                                  updateStatusData(newvalue!);
                                  setState(() {
                                    valueStatus = newvalue;
                                  });

                                  // print it to the console
                                  print("Selected value: $newvalue");
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
                      Container(
                        margin: const EdgeInsets.all(3.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.black),
                                    children: [
                                      const TextSpan(
                                        text: "Date of first symptom: ",
                                      ),
                                      TextSpan(
                                          text: widget.reportedCaseData[
                                                  'first_symptom_date'] ??
                                              formattedDateOnly),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDateofSymptoms,
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101));
                                    if (picked != null &&
                                        picked != selectedDateofSymptoms) {
                                      setState(() {
                                        selectedDateofSymptoms = picked;
                                        formattedDateOnly =
                                            "${selectedDateofSymptoms.year}-${selectedDateofSymptoms.month.toString().padLeft(2, '0')}-${selectedDateofSymptoms.day.toString().padLeft(2, '0')}";
                                        print(formattedDateOnly);
                                        widget.reportedCaseData[
                                                'first_symptom_date'] =
                                            formattedDateOnly;
                                        updateFirstDateOfSymptomsData(
                                            formattedDateOnly);
                                        User? user =
                                            FirebaseAuth.instance.currentUser;
                                        logAdminAction(
                                            'Edit Report - Date of First Symptom',
                                            user!.uid);
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Select date',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      Container(
                        margin: const EdgeInsets.all(3.0),
                        padding: const EdgeInsets.all(3.0),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Patient Admitted? : ",
                                  style: GoogleFonts.poppins(fontSize: 18),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      items: admitted
                                          .map(buildMenuItemAdmitted)
                                          .toList(),
                                      value: valueAdmitted ??
                                          widget.reportedCaseData[
                                              'patient_admitted'],
                                      hint: Text(widget.reportedCaseData[
                                              'patient_admitted'] ??
                                          valueAdmitted),
                                      onChanged: (value) {
                                        updatePatientAdmittedData(value!);
                                        User? user =
                                            FirebaseAuth.instance.currentUser;
                                        logAdminAction(
                                            'Edit Report - Patient Admitted',
                                            user!.uid);
                                        setState(() {
                                          valueAdmitted = value;
                                        });

                                        // print it to the console
                                        print("Selected value: $value");
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: valueAdmitted == 'Yes',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "If YES :",
                                    style: GoogleFonts.poppins(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Visibility(
                              visible: valueAdmitted == 'Yes',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          items: hospitalList
                                              .map(buildMenuItemHospital)
                                              .toList(),
                                          value: valueHospital ??
                                              widget.reportedCaseData[
                                                  'hospital_name'],
                                          hint: Text(widget.reportedCaseData[
                                                  'hospital_name'] ??
                                              valueHospital),
                                          onChanged: (value) {
                                            updateHostpitalData(value!);
                                            setState(() {
                                              valueHospital = value;
                                            });
                                            print("Selected value: $value");
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Visibility(
                                visible: valueHospital == 'Other' &&
                                    valueAdmitted == 'Yes',
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Please Specify',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    )
                                  ],
                                )),
                            const SizedBox(height: 8),
                            Visibility(
                              visible: valueHospital == 'Other' &&
                                  valueAdmitted == 'Yes',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: InputWidget(
                                      obscureText: false,
                                      controller: _otherHospitalController,
                                      labelText: 'Hospital Name',
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      updateHostpitalData(
                                          _otherHospitalController.text);
                                    },
                                    icon: const Icon(
                                      Icons.save,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                                    tooltip: 'Save',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Patient Recovered? : ",
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                items: recovered
                                    .map(buildMenuItemRecovered)
                                    .toList(),
                                value: valueRecovered ??
                                    widget
                                        .reportedCaseData['patient_recovered'],
                                hint: Text(widget.reportedCaseData[
                                        'patient_recovered'] ??
                                    valueRecovered),
                                onChanged: (value) {
                                  updatePatientRecoveredData(value!);
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  logAdminAction(
                                      'Edit Report - Patient Recovered',
                                      user!.uid);
                                  setState(() {
                                    // Update valueAdmitted only if the user selects a new value
                                    valueRecovered = value;
                                  });

                                  // print it to the console
                                  print("Selected value: $value");
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      _gap(),
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

  void updateStatusData(String selectedValue) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String docID = await fetchDocumentID();

    DocumentReference documentReference =
        firestore.collection('reports').doc(docID);

    valueRecovered = selectedValue == 'Recovered' ? 'Yes' : 'No';

    await documentReference.update({
      'status': selectedValue,
      'checked': 'Yes',
      'patient_recovered': valueRecovered,
    }).then((value) {
      print("Firestore data updated successfully!");
    }).catchError((error) {
      print("Error updating Firestore data: $error");
    });
    setState(() {
      valueRecovered;
      valueStatus;
    });
  }

  void updateFirstDateOfSymptomsData(String newDate) async {
    // Assuming you have a Firestore collection named 'reportedCases'
    CollectionReference reportedCases =
        FirebaseFirestore.instance.collection('reports');

    // Assuming you have a document ID for the specific case
    String documentID = await fetchDocumentID();

    // Update the document with the new date value
    await reportedCases.doc(documentID).update(
        {'first_symptom_date': newDate, 'checked': 'Yes'}).then((value) {
      print("Firestore data updated successfully!");
    }).catchError((error) {
      print("Error updating Firestore data: $error");
    });
  }

  void updatePatientAdmittedData(String selectedValue) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String docID = await fetchDocumentID();

    DocumentReference documentReference =
        firestore.collection('reports').doc(docID);

    await documentReference.update({
      'patient_admitted': valueAdmitted == 'Yes'
          ? valueAdmitted
          : (() {
              valueHospital = hospitalList[0];
              _otherHospitalController.text = '';
              return valueAdmitted;
            })(),
      'other_hospital': valueHospital == 'Other' ? 'Yes' : 'No',
      'checked': 'Yes'
    }).then((value) {
      print("Firestore data updated successfully!");
    }).catchError((error) {
      print("Error updating Firestore data: $error");
    });
  }

  void updateHostpitalData(String selectedValue) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String docID = await fetchDocumentID();

    DocumentReference documentReference =
        firestore.collection('reports').doc(docID);

    await documentReference.update({
      'hospital_name': valueHospital == hospitalList[0]
          ? ''
          : valueHospital == 'Other'
              ? _otherHospitalController.text
              : valueHospital,
      'other_hospital': valueHospital == 'Other' ? 'Yes' : 'No',
      'checked': 'Yes'
    }).then((value) {
      print("Firestore data updated successfully!");
    }).catchError((error) {
      print("Error updating Firestore data: $error");
    });
  }

  void updatePatientRecoveredData(String selectedValue) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String docID = await fetchDocumentID();

    DocumentReference documentReference =
        firestore.collection('reports').doc(docID);
    valueStatus = selectedValue == 'Yes' ? 'Recovered' : 'Probable';
    await documentReference.update({
      'patient_recovered': selectedValue,
      'status': valueStatus,
      'checked': 'Yes',
    }).then((value) {
      if (selectedValue == 'Yes') {
        _showSnackbarSuccess(context, "Patient Cleared");
      }
    }).catchError((error) {
      print("Error updating Firestore data: $error");
    });
    setState(() {
      valueStatus;
      valueRecovered;
    });
  }

  Future<String> getDocumentID() async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('reports');

    QuerySnapshot querySnapshot = await collectionRef
        .where('document_id', isEqualTo: widget.reportedCaseData['document_id'])
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

  void updateDataToFirebase() async {
    setState(() {
      _isSubmitting = true; // Begin submission
    });
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    //!Retrieve Doc ID
    String documentID = await fetchDocumentID();

    CollectionReference reports =
        FirebaseFirestore.instance.collection('reports');
    DocumentReference userDocRef =
        reports.doc(documentID); // Use the document_id here

    _buildProgressIndicator();

    Map<String, dynamic> updateData = {
      'patient_admitted': valueAdmitted,
      'hospital_name': valueHospital == hospitalList[0]
          ? ''
          : valueHospital == 'Other'
              ? _otherHospitalController.text
              : valueHospital,
      'other_hospital': valueHospital == 'Other' ? 'Yes' : 'No',
      'patient_recovered': valueRecovered,
      'checked': 'Yes'
    };

    userDocRef.update(updateData).then((value) {
      setState(() {
        _isSubmitting = false; // end submission
      });
      _showSnackbarSuccess(context, 'Success');
      logAdminAction('Edit Dengue Case Report Form', documentID);
    }).catchError((error) {
      setState(() {
        _isSubmitting = false; // end submission
      });
      _showSnackbarError(context, error.toString());
    });
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

    Map<String, dynamic> logEntry = {
      'admin_email': user?.email,
      'action': action,
      'document_id': documentId,
      'timestamp': formattedDateTime,
    };

    await adminLogs.add(logEntry);
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

Widget _gap() => const SizedBox(height: 16);
DropdownMenuItem<String> buildMenuItem(String sex) => DropdownMenuItem(
      value: sex,
      child: Text(
        sex,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
DropdownMenuItem<String> buildMenuItemStatus(String status) => DropdownMenuItem(
      value: status,
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
DropdownMenuItem<String> buildMenuItemAdmitted(String admitted) =>
    DropdownMenuItem(
      value: admitted,
      child: Text(
        admitted,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
DropdownMenuItem<String> buildMenuItemRecovered(String recovered) =>
    DropdownMenuItem(
      value: recovered,
      child: Text(
        recovered,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
DropdownMenuItem<String> buildMenuItemHospital(String hospital) =>
    DropdownMenuItem(
      value: hospital,
      child: Text(
        hospital,
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
