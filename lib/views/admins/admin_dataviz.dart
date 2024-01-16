import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:denguecare_firebase/charts/chartReports.dart';
import 'package:denguecare_firebase/charts/testchart.dart';
import 'package:denguecare_firebase/views/admins/admin_userreportdataviz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

List<List<dynamic>> data = [];

class AdminDataVizPage extends StatefulWidget {
  const AdminDataVizPage({super.key});

  @override
  State<AdminDataVizPage> createState() => _AdminDataVizPageState();
}

class _AdminDataVizPageState extends State<AdminDataVizPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool isUploading = false;

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Loading...',
            style: GoogleFonts.poppins(
              fontSize: 20,
            )),
        content: const CircularProgressIndicator(),
      ),
    );
  }

  void dismissLoadingDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // backgroundColor: Colors.white10,
      body: Column(
        children: [
          TabBar(
            labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
            labelColor: Colors.black,
            controller: _tabController,
            tabs: const [
              Tab(text: 'User Case Reports'),
              Tab(text: 'Dengue Line List'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AdminUserReportDataViz(),
                testChart(),
                // Add another widget for the second tab content
                // For example: YourSecondTabContent(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '1312312312',
        onPressed: () async {
          showLoadingDialog();
          await _pickAndUploadFile();
          dismissLoadingDialog();
        },
        tooltip: 'Pick A File',
        child: const Icon(Icons.add),
      ),
    ));
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

  Future<void> _pickAndUploadFile() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoading = true;
      isUploading = true;
    });

    try {
      FilePickerResult? pickedfile = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (pickedfile != null) {
        Uint8List bytes = pickedfile.files.first.bytes!;
        print(bytes);
        final csvString = String.fromCharCodes(bytes);
        List<List<dynamic>> csvTable =
            const CsvToListConverter().convert(csvString);

        List<List<dynamic>> data = csvTable;

        await process(data);
        logAdminAction('Import Data', user!.uid);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Set isLoading to false when processing is complete
        isUploading = false; // Set isUploading to false to hide progress
      });
    }
  }

  Future<void> process(List<List<dynamic>> data) async {
    await deleteAllDocumentsInCollection('denguelinelist');
    final CollectionReference addDLL =
        FirebaseFirestore.instance.collection('denguelinelist');
    for (var i = 1; i < data.length; i++) {
      var record = {
        'Region': data[i][0],
        'Province': data[i][1],
        'Muncity': data[i][2],
        'Streetpurok': data[i][3],
        'DateOfEntry': data[i][4],
        'DRU': data[i][5],
        'PatientNumber': data[i][6],
        'FirstName': data[i][7],
        'FamilyName': data[i][8],
        'FullName': data[i][9],
        'AgeYears': data[i][10],
        'AgeMons': data[i][11],
        'AgeDays': data[i][12],
        'Sex': data[i][13],
        'AddressOfDRU': data[i][14],
        'ProvOfDRU': data[i][15],
        'MuncityOfDRU': data[i][16],
        'DOB': data[i][17],
        'Admitted': data[i][18],
        'DAdmit': data[i][19],
        'DOnset': data[i][20],
        'Type': data[i][21],
        'LabTest': data[i][22],
        'LabRes': data[i][23],
        'ClinClass': data[i][24],
        'CaseClassification': data[i][25],
        'Outcome': data[i][26],
        'RegionOfDrU': data[i][27],
        'EPIID': data[i][28],
        'DateDied': data[i][29],
        'Icd10Code': data[i][30],
        'MorbidityMonth': data[i][31],
        'MorbidityWeek': data[i][32],
        'AdmitToEntry': data[i][33],
        'OnsetToAdmit': data[i][34],
        'SentinelSite': data[i][35],
        'DeleteRecord': data[i][36],
        'Year': data[i][37],
        'Recstatus': data[i][38],
        'UniqueKey': data[i][39],
        'NameOfDru': data[i][40],
        'ILHZ': data[i][41],
        'District': data[i][42],
        'Barangay': data[i][43],
        'TYPEHOSPITALCLINIC': data[i][44],
        'SENT': data[i][45],
        'ip': data[i][6],
        'ipgroup': data[i][47],
      };

      final existingRecords = await addDLL
          .where('FullName', isEqualTo: record['FullName'])
          .where('DateOfEntry', isEqualTo: record['DateOfEntry'])
          .get();

      if (existingRecords.docs.isEmpty) {
        await addDLL.add(record);
        print('Data Added');
      } else {
        print('Redundant data found for record $i');
      }
    }
  }

  /*Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      await _pickAndUploadFile();
      print('Permission Granted');
      // You can now use the storage
    } else if (status.isDenied) {
      print("Permission Denied");
    } else {
//    print("Permission Denied");
    }
  }*/
}
