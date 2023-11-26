import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_homepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String baseUrl = 'https://api.semaphore.co/api/v4/messages';
String apikey = dotenv.env['apikey'] ?? '';

class SemaphoreAPI {
  late String apikey;

  SemaphoreAPI() {
    _loadEnvironmentVariables();
  }

  Future<void> _loadEnvironmentVariables() async {
    await dotenv.load();
    apikey = dotenv.env['apikey'] ?? '';
  }
}

class AdminAnnouncementPage extends StatefulWidget {
  const AdminAnnouncementPage({super.key});

  @override
  State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  final apikey = dotenv.env['apikey'] ?? '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController announcementController = TextEditingController();
  final reference = FirebaseFirestore.instance.collection('users');
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
  late String _selectedPurok;

  @override
  void initState() {
    super.initState();
    _selectedPurok = puroklist.first; // Initialize with the first purok
  }

  @override
  void dispose() {
    announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Admin Announcements'),
          leading: BackButton(
            onPressed: () {
              Get.offAll(() => const AdminMainPage());
            },
          )),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo-no-background.png'),
                    const SizedBox(height: 20),
                    Text(
                      'SEND ANNOUNCEMENTS',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedPurok,
                      items: puroklist.map((purok) {
                        return DropdownMenuItem(
                          value: purok,
                          child: Text(purok),
                        );
                      }).toList(),
                      onChanged: (String? val) =>
                          setState(() => _selectedPurok = val ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Select Purok',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: announcementController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Announcement',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () async {
                            // Show a confirmation dialog
                            bool? confirmSend =
                                await _showConfirmationDialog(context);
                            if (confirmSend == true) {
                              sendSMSInBulk();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          },
                          child: Text(
                            'Send',
                            style: GoogleFonts.poppins(fontSize: 20),
                          )),
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

  Future<List<String>> getPhoneNumbers(String selectedPurok) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('purok', isEqualTo: selectedPurok)
        .get();
    List<String> numbers = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String numberString = doc['contact_number'];
      // ignore: avoid_print
      print('Raw number string: $numberString');
      numbers.addAll(numberString.split(',').map((e) => e.trim()));
    }
    // ignore: avoid_print
    print('Parsed numbers: $numbers');
    return numbers;
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to send the SMS?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User clicked "Cancel"
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User clicked "OK"
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void sendSMSInBulk() async {
    try {
      bool isSuccess = true;
      List<String> numbers = await getPhoneNumbers(_selectedPurok);
      for (String number in numbers) {
        isSuccess = await sendSMS(apikey, number, announcementController.text);
        if (!isSuccess) {
          break;
        }
      }

      if (isSuccess) {
        _showSnackbarSuccess('All SMS sent successfully');
        Get.offAll(() => const AdminMainPage());
      } else {
        _showSnackbarError('Failed to send SMS');
      }
    } catch (e) {
      _showSnackbarError('Failed to send SMS');
    }
  }

  Future<bool> sendSMS(String apikey, String number, String message) async {
    try {
      final parameters = {
        'apikey': apikey,
        'number': number,
        'message': message,
      };
      final response = await http.post(
        Uri.parse('https://api.semaphore.co/api/v4/messages'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: parameters,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void _showSnackbarSuccess(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _showSnackbarError(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}






// Future<void> sendBulk() async {
  //   final apikey = dotenv.env['apikey'] ?? '';
  //   try {
  //     List<String> numbers = await getPhoneNumbers(_selectedPurok);

  //     List<Future<void>> smsFutures = numbers
  //         .map((String number) =>
  //             sendSMS(apikey, number, announcementController.text))
  //         .toList();

  //     // Wait for all SMS futures to complete
  //     await Future.wait(smsFutures);
  //     _formKey.currentState!.reset();
  //   } catch (e) {
  //     _showSnackbarError('Failed to send SMS');
  //   }
  // }

  // Future<void> sendSMS(String apikey, String number, String message) async {
  //   try {
  //     final parameters = {
  //       'apikey': apikey,
  //       'number': number,
  //       'message': message,
  //     };
  //     final response = await http.post(
  //       Uri.parse('https://api.semaphore.co/api/v4/messages'),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body: parameters,
  //     );

  //     if (response.statusCode == 200) {
  //       _showSnackbarSuccess('SMS sent successfully');
  //       Get.offAll(() => const AdminMainPage());
  //     } else {
  //       _showSnackbarError('Failed to send SMS');
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //     _showSnackbarError(e.toString());
  //   }

  //   // phoneController.clear();
  //   announcementController.clear();
  // }