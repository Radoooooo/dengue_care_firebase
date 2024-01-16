import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/input_address_widget.dart';
import '../widgets/input_age_widget.dart';
import '../widgets/input_contact_number.dart';
import '../widgets/input_widget.dart';

class UserViewReportedCasesPage extends StatefulWidget {
  final Map<String, dynamic> reportedCaseData;
  const UserViewReportedCasesPage({super.key, required this.reportedCaseData});

  @override
  State<UserViewReportedCasesPage> createState() =>
      _UserViewReportedCasesPageState();
}

class _UserViewReportedCasesPageState extends State<UserViewReportedCasesPage> {
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

  final TextEditingController _hospitalnameController = TextEditingController();

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
    _hospitalnameController.text = widget.reportedCaseData['hospital_name'];
    valueRecovered = widget.reportedCaseData['patient_recovered'];
    valueAdmitted = widget.reportedCaseData['patient_admitted'];
    valueStatus = widget.reportedCaseData['status'];
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
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      _gap(),

                      InputWidget(
                        hintText: "Name",
                        obscureText: false,
                        initialVal: widget.reportedCaseData['name'],
                        enableTextInput: false,
                      ),
                      _gap(),
                      Row(
                        children: [
                          Expanded(
                            child: InputAgeWidget(
                              hintText: "Age",
                              obscureText: false,
                              enableTextInput: false,
                              initialVal:
                                  widget.reportedCaseData['age'].toString(),
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
                      InputContactNumber(
                        hintText: "Contact Number (10-digit)",
                        initialVal: widget.reportedCaseData['contact_number'],
                        enableTextInput: false,
                        obscureText: false,
                      ),
                      _gap(),
                      InputWidget(
                        hintText: "Address Line 1",
                        initialVal: widget.reportedCaseData['address_line1'],
                        obscureText: false,
                        enableTextInput: false,
                      ),
                      _gap(),
                      InputWidget(
                        hintText: "Address Line 2",
                        initialVal: widget.reportedCaseData['address_line2'],
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
                        child: Text("Symptoms",
                            style: Theme.of(context).textTheme.headlineSmall),
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
                          const Text("Status : "),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  items:
                                      status.map(buildMenuItemStatus).toList(),
                                  value: valueStatus ??
                                      widget.reportedCaseData['status'],
                                  hint: Text(
                                      widget.reportedCaseData['status'] ??
                                          valueStatus),
                                  onChanged: null),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text("Date of first symptom:"),
                                const SizedBox(width: 16),
                                Text(widget.reportedCaseData[
                                        'first_symptom_date'] ??
                                    formattedDateOnly),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                const Text("Patient Admitted? : "),
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
                                        onChanged: null),
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [Text("If YES :")],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _hospitalnameController,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Hospital name',
                                      prefixIcon:
                                          Icon(Icons.local_hospital_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _gap(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Patient Recovered? : "),
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
                                onChanged: null,
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
    // // Get the current date

    Map<String, dynamic> updateData = {
      'status': valueStatus,
      'first_symptom_date': formattedDateOnly,
      'patient_admitted': valueAdmitted,
      'hospital_name': _hospitalnameController.text,
      'patient_recovered': valueRecovered,
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
      child: Text(sex),
    );
DropdownMenuItem<String> buildMenuItemStatus(String status) => DropdownMenuItem(
      value: status,
      child: Text(status),
    );
DropdownMenuItem<String> buildMenuItemAdmitted(String admitted) =>
    DropdownMenuItem(
      value: admitted,
      child: Text(admitted),
    );
DropdownMenuItem<String> buildMenuItemRecovered(String recovered) =>
    DropdownMenuItem(
      value: recovered,
      child: Text(recovered),
    );
