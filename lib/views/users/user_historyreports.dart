import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_viewreportedcasespage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportsHistory extends StatefulWidget {
  const ReportsHistory({super.key});

  @override
  State<ReportsHistory> createState() => _ReportsHistoryState();
}

final FirebaseAuth auth = FirebaseAuth.instance;
final user = auth.currentUser;

class _ReportsHistoryState extends State<ReportsHistory> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Submitted Reports'),
            leading: BackButton(onPressed: () {
              Get.back();
            }),
          ),
          body: Center(
            child: SizedBox(
              width: 600,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .where('emailid', isEqualTo: user?.email)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      // Convert the Timestamp to DateTime
                      DateTime dateTime = (data['date'] as Timestamp).toDate();

                      // Format the DateTime to display only the date
                      String formattedDate =
                          DateFormat('MM/d/yyyy').format(dateTime);

                      return Container(
                        width: 50,
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: _getColorForStatus(data['status']),
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: ListTile(
                            textColor: Colors.white,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: data['firstName'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: data['lastName'],
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    const WidgetSpan(
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const TextSpan(text: ' '),
                                    TextSpan(
                                        text: data['age'].toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white)),
                                  ]),
                                ),
                              ],
                            ),
                            subtitle: RichText(
                              text: TextSpan(children: [
                                const WidgetSpan(
                                  child: Icon(
                                    Icons.contact_phone,
                                    color: Colors.white,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                    text: data['contact_number'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.white)),
                              ]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data['status'],
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    const WidgetSpan(
                                      child: Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const TextSpan(text: ' '),
                                    TextSpan(
                                        text: formattedDate,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.white)),
                                  ]),
                                ),
                                const SizedBox(
                                  width: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    // children: snapshot.data!.docs.map((DocumentSnapshot document) {

                    // }).toList(),
                  );
                },
              ),
            ),
          )),
    );
  }
}

Color _getColorForStatus(String status) {
  switch (status) {
    case 'Suspected':
      return Colors.blue;
    case 'Probable':
      return Colors.orange;
    case 'Confirmed':
      return Colors.red;
    case 'Recovered':
      return Colors.green;
    default:
      return Colors.white;
  }
}
