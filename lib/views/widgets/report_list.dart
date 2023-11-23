import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_viewreportedcasespage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportListWidget extends StatefulWidget {
  const ReportListWidget({super.key});

  @override
  State<ReportListWidget> createState() => _ReportListWidgetState();
}

class _ReportListWidgetState extends State<ReportListWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  String selectedSortOption = 'Unchecked';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                filteredReports = reports
                    .where((report) =>
                        report['firstName']
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                        report['lastName']
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                    .toList();
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search by Name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                'All',
                'Unchecked',
                'Suspected',
                'Probable',
                'Confirmed',
              ].map((option) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSortOption = option;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedSortOption == option
                          ? Colors
                              .blue // Change the color for the selected button
                          : Colors.green, // Default color for other buttons
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: selectedSortOption == 'All'
                ? FirebaseFirestore.instance
                    .collection('reports')
                    .orderBy(_getOrderByField(), descending: true)
                    .snapshots()
                : selectedSortOption == 'Unchecked'
                    ? FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy(_getOrderByField(), descending: true)
                        .where('checked', isEqualTo: 'No')
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy(_getOrderByField(), descending: true)
                        .where('status', isEqualTo: selectedSortOption)
                        .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Map<String, dynamic>> reports = snapshot.data!.docs
                  .map((doc) => doc.data())
                  .toList()
                  .cast<Map<String, dynamic>>();

              filteredReports = reports;
              if (_searchController.text.isNotEmpty) {
                filteredReports = filteredReports
                    .where((report) =>
                        report['firstName']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) ||
                        report['lastName']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                    .toList();
              }
              bool showBadge =
                  reports.any((report) => report['checked'] == 'No');

              return ListView.builder(
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = filteredReports[index];
                  // Convert the Timestamp to DateTime
                  DateTime dateTime = (data['date'] as Timestamp).toDate();

                  // Format the DateTime to display only the date
                  String formattedDate =
                      DateFormat('MM/d/yyyy').format(dateTime);

                  return Container(
                    width: 50,
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Get.to(() =>
                            AdminViewReportedCasesPage(reportedCaseData: data));
                      },
                      child: badges.Badge(
                        showBadge: showBadge && data['checked'] == 'No',
                        badgeStyle: const badges.BadgeStyle(
                          padding: EdgeInsets.all(1),
                        ),
                        position: badges.BadgePosition.topEnd(end: 1),
                        badgeContent: showBadge && data['checked'] == 'No'
                            ? const Icon(
                                Icons.priority_high,
                                color: Colors.white,
                                size: 24,
                              )
                            : const SizedBox(),
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
                                  text: TextSpan(children: [
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
                                  ]),
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
                                        text: data['age'],
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
                                IconButton(
                                  onPressed: () {
                                    // Get.offAll(() => AdminViewReportedCasesPage(
                                    //     reportedCaseData: data));
                                    Get.to(() => AdminViewReportedCasesPage(
                                        reportedCaseData: data));
                                  },
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: Colors.white,
                                    size: 30,
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
                // children: snapshot.data!.docs.map((DocumentSnapshot document) {

                // }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _setSortOption(String option) {
    setState(() {
      selectedSortOption = option;
      _filterReports();
    });
  }

  String _getOrderByField() {
    switch (selectedSortOption) {
      case 'All':
        return 'date';
      case 'Unchecked':
        return 'checked';
      case 'Suspected':
      case 'Probable':
      case 'Confirmed':
        return 'status';
      default:
        return 'date';
    }
  }

  void _filterReports() {
    filteredReports = reports.where((report) {
      return (report['firstName']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              report['lastName']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase())) &&
          _checkStatusFilter(report);
    }).toList();
  }

  bool _checkStatusFilter(Map<String, dynamic> report) {
    if (selectedSortOption == 'All') {
      return true;
    } else if (selectedSortOption == 'Unchecked') {
      return report['checked'] == 'No';
    } else {
      return report['status'] == selectedSortOption;
    }
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
    default:
      return Colors.white;
  }
}

class LengthIndicator extends StatelessWidget {
  const LengthIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the length of the ListView
    int length = 0;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('reports')
          .where('checked', isEqualTo: 'No')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          length = snapshot.data!.docs.length;
          print(length);
          return Text(
            '$length',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          );
        }
        return Text('$length',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12));
      },
    );
  }
}
