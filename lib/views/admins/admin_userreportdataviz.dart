import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:denguecare_firebase/charts/testchart.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

DateTime selectedDateofSymptoms = DateTime.now();
DateTime selectedDateofSymptoms2 = DateTime.now();
String? formattedDateOnly;
String dateMonth = '';
String dateYear = '';
int sCase = 0;
int dateMonthInt = 0;
int dateYearInt = 0;
DateTime? picked = DateTime.now();
DateTime? picked2 = DateTime.now();
List<LineSeries<DengueData, int>> yearlySeriesMonthS = [];
List<LineSeries<DengueData, int>> yearlySeriesMonthP = [];
List<LineSeries<DengueData, int>> yearlySeriesMonthC = [];
List<piechartData> pieChartYR = [];
List<piechartData> pieChartYR2 = [];
double b1 = 0;
double b2 = 0;

List<DengueData> chart = [];
List<DengueData> chart2 = [];
List<DengueData> chart3 = [];
List<DengueData> chartYear = [];
List<DengueData> yearlyData = [];
List<LineSeries<DengueData, int>> yearlySeries = [];

List<LineSeries<DengueData, int>> yearlySeriesWeek = [];
List<piechartData> pieChart = [];

List<StreetPurokData> barChart = [];
List<StreetPurokData> barChartYR = [];
List<int> listYear = [2023];
String ageGroup = '';
String hAgeGroup = '';
String lAgeGroup = '';

String hAGE = '';
String lAGE = '';

int newValue = 0;
int selectedYear = DateTime.now().year.toInt();
int selectedYear2 = DateTime.now().year.toInt();
double minYear = 0;
double maxYear = 0;

double a1 = 0;
double a2 = 0;

late TooltipBehavior _tooltipBehavior;
late TooltipBehavior _tooltipBehavior2;
late TooltipBehavior _tooltipBehavior3;
late TooltipBehavior _tooltipBehavior4;
late ZoomPanBehavior _zoomPanBehavior;

class DengueData {
  DengueData(this.x, this.y);
  final int x;
  final int y;
}

class piechartData {
  piechartData(this.status, this.number, this.color);
  String status;
  double number;
  Color color;
}

class StreetPurokData {
  StreetPurokData(this.purok, this.cases);
  String purok;
  int cases;
}

class AdminUserReportDataViz extends StatefulWidget {
  const AdminUserReportDataViz({super.key});

  @override
  State<AdminUserReportDataViz> createState() => _AdminUserReportDataVizState();
}

class _AdminUserReportDataVizState extends State<AdminUserReportDataViz> {
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title:
            Text('Clearing Data...', style: GoogleFonts.poppins(fontSize: 20)),
        content: const CircularProgressIndicator(),
      ),
    );
  }

  void dismissLoadingDialog() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltipBehavior2 = TooltipBehavior(enable: true);
    _tooltipBehavior3 = TooltipBehavior(enable: true);
    _tooltipBehavior4 = TooltipBehavior(enable: true);
    _zoomPanBehavior =
        ZoomPanBehavior(enableMouseWheelZooming: true, enablePinching: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        getListYear(),
        getYearlyDataMonth(selectedYear),
        getYearlyDataWeek(selectedYear),
        getDataYear(),
        generateYearlySeries(),
        generateMonthS(selectedDateofSymptoms, selectedDateofSymptoms2),
        //generateMonthP(selectedDateofSymptoms, selectedDateofSymptoms2),
        generateMonthC(selectedDateofSymptoms, selectedDateofSymptoms2),
        generateYearlySeriesWeek(selectedYear, selectedYear2),
        getDataYearRange(selectedYear, selectedYear2),
        //queryAgeGroupsCount(selectedYear),
        queryPatientRecoveredCountYearRange(
            selectedDateofSymptoms, selectedDateofSymptoms2),
        queryPatientAdmittedCountYearRange(
            selectedDateofSymptoms, selectedDateofSymptoms2),
        getPurokCasesYR(selectedYear, selectedYear2),
        getPurokCases(selectedYear),
      ]),
      builder: (context, snapshot) {
        if (chart.isNotEmpty) {
          barChartYR.sort((a, b) => a.cases.compareTo(b.cases));

          minYear = listYear.first - 1;
          maxYear = listYear.last + 1;
        } else {}
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _gap(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('From: ',
                            style: GoogleFonts.poppins(fontSize: 20)),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDateofSymptoms,
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null &&
                                picked != selectedDateofSymptoms) {
                              selectedDateofSymptoms = picked;
                              print('Selected Symptoms 1:');
                              print(picked);
                            }
                          },
                          child: Text(
                            'Select date',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        Text('To: ', style: GoogleFonts.poppins(fontSize: 20)),
                        ElevatedButton(
                          onPressed: () async {
                            DateTime? picked2 = await showDatePicker(
                                context: context,
                                initialDate: selectedDateofSymptoms2,
                                firstDate: DateTime(2015, 8),
                                lastDate: DateTime(2101));
                            if (picked2 != null &&
                                picked2 != selectedDateofSymptoms2) {
                              selectedDateofSymptoms2 = picked2;
                              print('Selected Symptoms 2:');
                              print(picked2);
                            }
                          },
                          child: Text(
                            'Select date',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            generateMonthS(selectedDateofSymptoms,
                                selectedDateofSymptoms2);
                            generateMonthP(selectedDateofSymptoms,
                                selectedDateofSymptoms2);
                            generateMonthC(selectedDateofSymptoms,
                                selectedDateofSymptoms2);
                            setState(() {
                              //hAGE = findHighCasesAgeGroupYR(pieChartYR);
                              //lAGE = findLowCasesAgeGroupYR(pieChartYR);
                            });
                          },
                          child: Text('Filter',
                              style: GoogleFonts.poppins(fontSize: 20)),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          SfCartesianChart(
                            title: ChartTitle(
                                text: "Monthly Active Cases(Suspected)",
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Month",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                minimum: 0,
                                maximum: 12,
                                interval: 1),
                            primaryYAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Number of Active Cases",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20))),
                            tooltipBehavior: _tooltipBehavior,
                            series: yearlySeriesMonthS,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Active Cases(Month): ${findMonthWithHighestCasesYM(selectedYear, selectedYear2)}\nLowest Active Cases(Month): ${findMonthWithLowestCasesYM(selectedYear, selectedYear2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          SfCartesianChart(
                            title: ChartTitle(
                                text: "Monthly Active Cases(Probable)",
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Month",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                minimum: 0,
                                maximum: 12,
                                interval: 1),
                            primaryYAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Number of Active Cases",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20))),
                            tooltipBehavior: _tooltipBehavior2,
                            series: yearlySeriesMonthP,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Active Cases(Month): ${findMonthWithHighestCasesYM(selectedYear, selectedYear2)}\nLowest Active Cases(Month): ${findMonthWithLowestCasesYM(selectedYear, selectedYear2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          SfCartesianChart(
                            title: ChartTitle(
                                text: "Monthly Active Cases(Confirmed)",
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Month",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                minimum: 0,
                                maximum: 12,
                                interval: 1),
                            primaryYAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Number of Active Cases",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20))),
                            tooltipBehavior: _tooltipBehavior3,
                            series: yearlySeriesMonthC,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Active Cases(Month): ${findMonthWithHighestCasesYM(selectedYear, selectedYear2)}\nLowest Active Cases(Month): ${findMonthWithLowestCasesYM(selectedYear, selectedYear2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Patient Recovered Pie Chart',
                                    textStyle: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                series: <CircularSeries>[
                                  PieSeries<piechartData, String>(
                                    dataSource: pieChartYR,
                                    pointColorMapper: (piechartData data, _) =>
                                        data.color,
                                    xValueMapper: (piechartData data, _) =>
                                        data.status,
                                    yValueMapper: (piechartData data, _) =>
                                        data.number,
                                    dataLabelMapper: (piechartData data, _) =>
                                        '${data.status}:${data.number}',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Yes: ${a1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('No: ${a2.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Patient Admitted Pie Chart',
                                    textStyle: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                series: <CircularSeries>[
                                  PieSeries<piechartData, String>(
                                    dataSource: pieChartYR2,
                                    pointColorMapper: (piechartData data, _) =>
                                        data.color,
                                    xValueMapper: (piechartData data, _) =>
                                        data.status,
                                    yValueMapper: (piechartData data, _) =>
                                        data.number,
                                    dataLabelMapper: (piechartData data, _) =>
                                        '${data.status}:${data.number}',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Yes: ${b1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('No: ${b2.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}

Future<List<piechartData>> queryAgeGroupsCount(int year) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  double ageGroupCount = 0;
  double ageGroupCount2 = 0;
  double ageGroupCount3 = 0;
  double ageGroupCount4 = 0;

  int childAgeMax = 16;

  QuerySnapshot querySnapshot = await firestore
      .collection('denguelinelist')
      .where('AgeYears', isLessThanOrEqualTo: childAgeMax)
      .where('Year', isEqualTo: year)
      .get();

  ageGroupCount = querySnapshot.size.toDouble();
  pieChart = [];
  pieChart.add(piechartData('Child', ageGroupCount, Colors.blue));

  int yAdultAgeMin = 17;
  int yAdultAgeMax = 30;

  QuerySnapshot querySnapshot2 = await firestore
      .collection('denguelinelist')
      .where('AgeYears', isGreaterThanOrEqualTo: yAdultAgeMin)
      .where('AgeYears', isLessThanOrEqualTo: yAdultAgeMax)
      .where('Year', isEqualTo: year)
      .get();

  ageGroupCount2 = querySnapshot2.size.toDouble();
  pieChart.add(piechartData('Young Adult', ageGroupCount2, Colors.red));

  int mAdultAgeMin = 31;
  int mAdultAgeMax = 45;

  QuerySnapshot querySnapshot3 = await firestore
      .collection('denguelinelist')
      .where('AgeYears', isGreaterThanOrEqualTo: mAdultAgeMin)
      .where('AgeYears', isLessThanOrEqualTo: mAdultAgeMax)
      .where('Year', isEqualTo: year)
      .get();

  ageGroupCount3 = querySnapshot3.size.toDouble();
  pieChart.add(piechartData('Middle Adult', ageGroupCount3, Colors.green));

  int oAdultAgeMin = 45;

  QuerySnapshot querySnapshot4 = await firestore
      .collection('denguelinelist')
      .where('AgeYears', isGreaterThan: oAdultAgeMin)
      .where('Year', isEqualTo: year)
      .get();

  ageGroupCount4 = querySnapshot4.size.toDouble();
  pieChart.add(piechartData('Old Adult', ageGroupCount4, Colors.yellow));

  a1 = ageGroupCount;
  a2 = ageGroupCount2;
  a3 = ageGroupCount3;
  a4 = ageGroupCount4;

  return pieChart;
}

Future<List<int>> getListYear() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  QuerySnapshot querySnapshot = await firestore
      .collection('reports') // Replace with your actual collection name
      .orderBy('date', descending: false)
      .get();

  Set<int> uniqueYears = <int>{};

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime timestamp =
        data['date'].toDate(); // Assuming 'date' is the timestamp field
    uniqueYears.add(timestamp.year);
  }

  return uniqueYears.toList();
}

Future<List<StreetPurokData>> getPurokCases(int year) async {
  try {
    String x = 'Streetpurok';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot = await collection.get();

    Map<String, int> casesByPurok = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x) && data['Year'] == year) {
        var value = data[x];
        casesByPurok[value] = (casesByPurok[value] ?? 0) + 1;
      }
    }

    barChart = [];
    casesByPurok.forEach((x, y) {
      barChart.add(StreetPurokData(x, y));
    });

    return Future.delayed(const Duration(seconds: 1), () {
      return barChart;
    });
  } catch (e) {
    print('BarChart Error');
    return Future.value([]);
  }
}

void logAdminAction(String action, String documentId) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  CollectionReference adminLogs =
      FirebaseFirestore.instance.collection('admin_logs');

  DateTime currentDateTime = DateTime.now();

  String formattedDateTime = "${currentDateTime.toLocal()}";

  Map<String, dynamic> logEntry = {
    'admin_email': user?.email,
    'action': action,
    'document_id': documentId,
    'timestamp': formattedDateTime,
  };

  await adminLogs.add(logEntry);
}

String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return '';
  }
}

Widget _gap() => const SizedBox(height: 8);

Future<List<ChartSeries<DengueData, int>>> generateMonthS(
    DateTime? dayTime1, DateTime? dayTime2) async {
  yearlySeriesMonthS = [];
  List<int> listYear = await getListYear();
  List<int> newlistYear = [];

  try {
    for (int x in listYear) {
      if (x >= dayTime1!.year.toInt() && x <= dayTime2!.year.toInt()) {
        newlistYear.add(x);
      }
    }

    for (int year in newlistYear) {
      String x = 'Suspected';
      CollectionReference collection =
          FirebaseFirestore.instance.collection('reports');
      QuerySnapshot querySnapshot =
          await collection.orderBy('date', descending: false).get();

      // Reset the map for each year
      Map<int, int> valueL = {};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime documentDate = data['date'].toDate();

        dateMonth = documentDate.month.toString();
        dateMonthInt = int.tryParse(dateMonth)!;
        dateYear = documentDate.year.toString();
        dateYearInt = int.tryParse(dateYear)!;

        if (data['status'] == x &&
            documentDate.isAfter(dayTime1!) &&
            documentDate.isBefore(dayTime2!) &&
            dateYearInt == year) {
          var value = dateMonthInt;
          valueL[value] = (valueL[value] ?? 0) + 1;
        }
      }

      yearlyData = [];
      Map<int, int> counts = valueL;

      counts.forEach((x, y) {
        yearlyData.add(DengueData(x, y));
      });

      yearlySeriesMonthS.add(LineSeries<DengueData, int>(
        dataSource: yearlyData,
        xValueMapper: (DengueData data, _) => data.x,
        yValueMapper: (DengueData data, _) => data.y,
        name: 'Year: $year',
        markerSettings: const MarkerSettings(isVisible: true),
      ));
    }

    return yearlySeriesMonthS;
  } catch (e) {
    // Handle any potential errors, e.g., network issues or Firestore exceptions
    print('Error getting count: $e');
    return yearlySeriesMonthS; // Return a special value to indicate an error
  }
}

Future<List<ChartSeries<DengueData, int>>> generateMonthP(
    DateTime? dayTime1, DateTime? dayTime2) async {
  yearlySeriesMonthP = [];
  List<int> listYear = await getListYear();
  List<int> newlistYear = [];

  try {
    for (int x in listYear) {
      if (x >= dayTime1!.year.toInt() && x <= dayTime2!.year.toInt()) {
        newlistYear.add(x);
      }
    }

    for (int year in newlistYear) {
      String x = 'Probable';
      CollectionReference collection =
          FirebaseFirestore.instance.collection('reports');
      QuerySnapshot querySnapshot =
          await collection.orderBy('date', descending: false).get();

      // Reset the map for each year
      Map<int, int> valueL = {};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime documentDate = data['date'].toDate();

        dateMonth = documentDate.month.toString();
        dateMonthInt = int.tryParse(dateMonth)!;
        dateYear = documentDate.year.toString();
        dateYearInt = int.tryParse(dateYear)!;

        if (data['status'] == x &&
            documentDate.isAfter(dayTime1!) &&
            documentDate.isBefore(dayTime2!) &&
            dateYearInt == year) {
          var value = dateMonthInt;
          valueL[value] = (valueL[value] ?? 0) + 1;
        }
      }

      yearlyData = [];
      Map<int, int> counts = valueL;

      counts.forEach((x, y) {
        yearlyData.add(DengueData(x, y));
      });

      yearlySeriesMonthP.add(LineSeries<DengueData, int>(
        dataSource: yearlyData,
        xValueMapper: (DengueData data, _) => data.x,
        yValueMapper: (DengueData data, _) => data.y,
        name: 'Year: $year',
        markerSettings: const MarkerSettings(isVisible: true),
      ));
    }

    return yearlySeriesMonthP;
  } catch (e) {
    // Handle any potential errors, e.g., network issues or Firestore exceptions
    print('Error getting count: $e');
    return yearlySeriesMonthP; // Return a special value to indicate an error
  }
}

Future<List<ChartSeries<DengueData, int>>> generateMonthC(
    DateTime? dayTime1, DateTime? dayTime2) async {
  yearlySeriesMonthC = [];
  List<int> listYear = await getListYear();
  List<int> newlistYear = [];

  try {
    for (int x in listYear) {
      if (x >= dayTime1!.year.toInt() && x <= dayTime2!.year.toInt()) {
        newlistYear.add(x);
      }
    }

    for (int year in newlistYear) {
      String x = 'Confirmed';
      CollectionReference collection =
          FirebaseFirestore.instance.collection('reports');
      QuerySnapshot querySnapshot =
          await collection.orderBy('date', descending: false).get();

      // Reset the map for each year
      Map<int, int> valueL = {};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime documentDate = data['date'].toDate();

        dateMonth = documentDate.month.toString();
        dateMonthInt = int.tryParse(dateMonth)!;
        dateYear = documentDate.year.toString();
        dateYearInt = int.tryParse(dateYear)!;

        if (data['status'] == x &&
            documentDate.isAfter(dayTime1!) &&
            documentDate.isBefore(dayTime2!) &&
            dateYearInt == year) {
          var value = dateMonthInt;
          valueL[value] = (valueL[value] ?? 0) + 1;
        }
      }

      yearlyData = [];
      Map<int, int> counts = valueL;

      counts.forEach((x, y) {
        yearlyData.add(DengueData(x, y));
      });

      yearlySeriesMonthC.add(LineSeries<DengueData, int>(
        dataSource: yearlyData,
        xValueMapper: (DengueData data, _) => data.x,
        yValueMapper: (DengueData data, _) => data.y,
        name: 'Year: $year',
        markerSettings: const MarkerSettings(isVisible: true),
      ));
    }

    return yearlySeriesMonthC;
  } catch (e) {
    // Handle any potential errors, e.g., network issues or Firestore exceptions
    print('Error getting count: $e');
    return yearlySeriesMonthC; // Return a special value to indicate an error
  }
}

Future<List<piechartData>> queryPatientRecoveredCountYearRange(
    DateTime? dayTime1, DateTime? dayTime2) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  double yes2 = 0;
  double no2 = 0;

  QuerySnapshot querySnapshot = await firestore
      .collection('reports')
      .where('patient_recovered', isEqualTo: 'Yes')
      .get();

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      yes2 = yes2 + 1;
    }
  }

  pieChartYR = [];
  pieChartYR.add(piechartData('Yes', yes2, Colors.blue));

  QuerySnapshot querySnapshot2 = await firestore
      .collection('reports')
      .where('patient_recovered', isEqualTo: 'No')
      .get();

  for (var doc in querySnapshot2.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      no2 = no2 + 1;
    }
  }

  pieChartYR.add(piechartData('No', no2, Colors.red));

  a1 = yes2;
  a2 = no2;

  return pieChartYR;
}

Future<List<piechartData>> queryPatientAdmittedCountYearRange(
    DateTime? dayTime1, DateTime? dayTime2) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  double yes = 0;
  double no = 0;

  QuerySnapshot querySnapshot = await firestore
      .collection('reports')
      .where('patient_admitted', isEqualTo: 'Yes')
      .get();

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      yes = yes + 1;
    }
  }

  pieChartYR2 = [];
  pieChartYR2.add(piechartData('Yes', yes, Colors.blue));

  QuerySnapshot querySnapshot2 = await firestore
      .collection('reports')
      .where('patient_admitted', isEqualTo: 'No')
      .get();

  for (var doc in querySnapshot2.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      no = no + 1;
    }
  }

  pieChartYR2.add(piechartData('No', no, Colors.red));

  b1 = yes;
  b2 = no;

  return pieChartYR2;
}
/*
Future<List<ChartSeries<DengueData, int>>> generateYearlySeriesWeek(
    int year1, int year2) async {
  yearlySeriesWeek = [];
  List<int> listYear = await getListYear();
  List<int> newlistYear = [];

  for (int x in listYear) {
    if (x >= year1 && x <= year2) {
      newlistYear.add(x);
    }
  }

  for (int year in newlistYear) {
    String x = 'MorbidityWeek';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot =
        await collection.orderBy('MorbidityWeek', descending: false).get();

    Map<int, int> valueL = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x) && data['Year'] == year) {
        var value = data[x];
        valueL[value] = (valueL[value] ?? 0) + 1;
      }
    }

    yearlyData = [];
    Map<int, int> counts = valueL;

    counts.forEach((x, y) {
      yearlyData.add(DengueData(x, y));
    });
    yearlySeriesWeek.add(LineSeries<DengueData, int>(
      dataSource: yearlyData,
      xValueMapper: (DengueData data, _) => data.x,
      yValueMapper: (DengueData data, _) => data.y,
      name: 'Year: $year',
      markerSettings: const MarkerSettings(isVisible: true),
    ));
  }

  return yearlySeriesWeek;
}

Future<List<DengueData>> getDataYearRange(int year1, int year2) async {
  try {
    String x = 'Year';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot =
        await collection.orderBy('Year', descending: false).get();

    Map<int, int> valueL = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x)) {
        var value = data[x];
        valueL[value] = (valueL[value] ?? 0) + 1;
      }
    }

    chartYear = [];
    Map<int, int> counts = valueL;
    counts.forEach((x, y) {
      if (x >= year1 && x <= year2) {
        chartYear.add(DengueData(x, y));
      }
    });

    return chartYear;
  } catch (e) {
    print('Chart3 Error');
    return Future.value([]);
  }
}

Future<List<piechartData>> queryAgeGroupsCountYearRange(
    int year1, int year2) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  double ageGroupCount = 0;
  double ageGroupCount2 = 0;
  double ageGroupCount3 = 0;
  double ageGroupCount4 = 0;

  int childAgeMax = 16;
  int yAdultAgeMin = 17;
  int yAdultAgeMax = 30;
  int mAdultAgeMin = 31;
  int mAdultAgeMax = 45;
  int oAdultAgeMin = 45;

  List<int> listYear = await getListYear();
  List<int> newlistYear = [];

  for (int x in listYear) {
    if (x >= year1 && x <= year2) {
      newlistYear.add(x);
    }
  }

  for (int x in newlistYear) {
    QuerySnapshot querySnapshot = await firestore
        .collection('denguelinelist')
        .where('AgeYears', isLessThanOrEqualTo: childAgeMax)
        .where('Year', isEqualTo: x)
        .get();

    ageGroupCount = ageGroupCount + querySnapshot.size.toDouble();
    pieChartYR = [];
    pieChartYR.add(piechartData('Child', ageGroupCount, Colors.blue));

    QuerySnapshot querySnapshot2 = await firestore
        .collection('denguelinelist')
        .where('AgeYears', isGreaterThanOrEqualTo: yAdultAgeMin)
        .where('AgeYears', isLessThanOrEqualTo: yAdultAgeMax)
        .where('Year', isEqualTo: x)
        .get();

    ageGroupCount2 = ageGroupCount2 + querySnapshot2.size.toDouble();
    pieChartYR.add(piechartData('Young Adult', ageGroupCount2, Colors.red));

    QuerySnapshot querySnapshot3 = await firestore
        .collection('denguelinelist')
        .where('AgeYears', isGreaterThanOrEqualTo: mAdultAgeMin)
        .where('AgeYears', isLessThanOrEqualTo: mAdultAgeMax)
        .where('Year', isEqualTo: x)
        .get();

    ageGroupCount3 = ageGroupCount3 + querySnapshot3.size.toDouble();
    pieChartYR.add(piechartData('Middle Adult', ageGroupCount3, Colors.green));

    QuerySnapshot querySnapshot4 = await firestore
        .collection('denguelinelist')
        .where('AgeYears', isGreaterThan: oAdultAgeMin)
        .where('Year', isEqualTo: x)
        .get();

    ageGroupCount4 = ageGroupCount4 + querySnapshot4.size.toDouble();
    pieChartYR.add(piechartData('Old Adult', ageGroupCount4, Colors.yellow));
  }

  a1 = ageGroupCount;
  a2 = ageGroupCount2;
  a3 = ageGroupCount3;
  a4 = ageGroupCount4;

  return pieChartYR;
}

Future<List<StreetPurokData>> getPurokCasesYR(int year1, int year2) async {
  try {
    String x = 'Streetpurok';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot = await collection.get();

    Map<String, int> casesByPurok = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x) &&
          data['Year'] >= year1 &&
          data['Year'] <= year2) {
        var value = data[x];
        casesByPurok[value] = (casesByPurok[value] ?? 0) + 1;
      }
    }

    barChartYR = [];
    casesByPurok.forEach((x, y) {
      barChartYR.add(StreetPurokData(x, y));
    });

    return Future.delayed(const Duration(seconds: 1), () {
      return barChartYR;
    });
  } catch (e) {
    print('BarChart Error');
    return Future.value([]);
  }
}

String findMonthWithHighestCasesYM(int year1, int year2) {
  String? yearH = '';
  String highM = '';
  String gethighM = '';
  int maxMonth = 0;
  int maxCases = 0;
  int yearV = 0;

  String? series1 = '';

  for (LineSeries<DengueData, int> series in yearlySeries) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      if (series.dataSource.isNotEmpty) {
        for (DengueData data in series.dataSource!) {
          if (maxCases < data.y) {
            maxCases = data.y;
            maxMonth = data.x;
          }
        }
      }
    } else {
      return highM;
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeries) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      if (series.dataSource.isNotEmpty) {
        for (DengueData data in series.dataSource!) {
          if (maxCases == data.y) {
            yearH = series.name;
            maxCases = data.y;
            maxMonth = data.x;
            gethighM = getMonthName(maxMonth) + '(' + yearH.toString() + ')';
            highM = highM + ' ' + gethighM;
          }
        }
      } else {
        return highM;
      }
    }
  }

  return highM;
}

String findMonthWithLowestCasesYM(int year1, int year2) {
  String? yearH = '';
  String lowM = '';
  String getLowM = '';
  int minMonth = 0;
  int minCases = 999999999; // Initialize to a large value
  int yearV = 0;

  String? series1 = '';

  for (LineSeries<DengueData, int> series in yearlySeries) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (minCases > data.y) {
          minCases = data.y;
          minMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeries) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (minCases == data.y) {
          yearH = series.name;
          minCases = data.y;
          minMonth = data.x;
          getLowM = getMonthName(minMonth) + '(' + yearH.toString() + ')';
          lowM = lowM + ' ' + getLowM;
        }
      }
    }
  }

  return lowM;
}

String findWeekWithHighestCasesYM(int year1, int year2) {
  String? yearH = '';
  String highW = '';
  String getHighW = '';
  int maxWeek = 0;
  int maxCases = 0;
  int yearV = 0;

  String? series1 = '';

  for (LineSeries<DengueData, int> series in yearlySeriesWeek) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (maxCases < data.y) {
          maxCases = data.y;
          maxWeek = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesWeek) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (maxCases == data.y) {
          yearH = series.name;
          maxCases = data.y;
          maxWeek = data.x;
          getHighW = maxWeek.toString() + '(' + yearH.toString() + ')';
          highW = highW + ' ' + getHighW;
        }
      }
    }
  }

  return highW;
}

String findWeekWithLowestCasesYM(int year1, int year2) {
  String? yearH = '';
  String lowW = '';
  String getLowW = '';
  int minWeek = 0;
  int minCases = 999999999; // Initialize to a large value
  int yearV = 0;

  String? series1 = '';

  for (LineSeries<DengueData, int> series in yearlySeriesWeek) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (minCases > data.y) {
          minCases = data.y;
          minWeek = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesWeek) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= year1 && yearV <= year2) {
      for (DengueData data in series.dataSource!) {
        if (minCases == data.y) {
          yearH = series.name;
          minCases = data.y;
          minWeek = data.x;
          getLowW = minWeek.toString() + '(' + yearH.toString() + ')';
          lowW = lowW + ' ' + getLowW;
        }
      }
    }
  }

  return lowW;
}

String findYearWithHighestCasesYM(List<DengueData> data) {
  String highW = '';
  String getHighW = '';
  int maxWeek = 0;
  int maxCases = 0;
  int yearV = 0;

  for (DengueData entry in data) {
    if (entry.y > maxCases) {
      maxCases = entry.y;
      maxWeek = entry.x;
      //getHighW = highW;
      //highW = highW + ' ' + getHighW;
    }
  }

  for (DengueData entry in data) {
    if (entry.y == maxCases) {
      maxCases = entry.y;
      maxWeek = entry.x;
      getHighW = maxWeek.toString();
      highW = highW + ' ' + getHighW;
    }
  }

  return highW;
}

String findYearLowestCaseYM(List<DengueData> data) {
  String getLowW = '';
  int minWeek = 0;
  int minCases = data.isNotEmpty ? data[0].y : 0;
  String lowW = '';

  if (minCases == null) {
    print('null');
    return lowW;
  } else {
    for (DengueData entry in data) {
      if (entry.y <= minCases) {
        minCases = entry.y;
        minWeek = entry.x;
      }
    }

    for (DengueData entry in data) {
      if (entry.y == minCases) {
        minCases = entry.y;
        minWeek = entry.x;
        getLowW = minWeek.toString();
        lowW = lowW + ' ' + getLowW;
      }
    }
    return lowW;
  }
}

String findHighCasesAgeGroupYR(List<piechartData> data) {
  double Cases = 0;
  String getAgeGroup = '';

  if (pieChartYR.isEmpty) {
    print('data is empty');
    return hAgeGroup;
  } else {
    if (hAgeGroup == '') {
      for (piechartData entry in pieChartYR) {
        if (entry.number > Cases) {
          Cases = entry.number;
          ageGroup = entry.ageGroup;
        }
      }

      for (piechartData entry in pieChartYR) {
        if (entry.number == Cases) {
          Cases = entry.number;
          ageGroup = entry.ageGroup;
          getAgeGroup = ageGroup;
          hAgeGroup = hAgeGroup + ' ' + getAgeGroup;
        }
      }
    }
  }

  return hAgeGroup;
}

String findLowCasesAgeGroupYR(List<piechartData> data) {
  double cases = data.isNotEmpty ? data[0].number : 0;

  String getAgeGroup = '';

  String ageGroup = '';
  if (pieChartYR.isEmpty) {
    print('data is empty');

    return lAgeGroup;
  } else {
    if (lAgeGroup == '') {
      for (piechartData entry in data) {
        if (entry.number <= cases) {
          cases = entry.number;
          ageGroup = entry.ageGroup;
        }
      }

      for (piechartData entry in data) {
        if (entry.number == cases) {
          ageGroup = entry.ageGroup;
          getAgeGroup = ageGroup;
          lAgeGroup = lAgeGroup + ' ' + getAgeGroup;
        }
      }
    }

    return lAgeGroup;
  }
}

String findHighestCaseSPYR(List<StreetPurokData> data) {
  String getHighSP = '';
  String sPurok = '';
  int maxCases = data.isNotEmpty ? data[0].cases : 0;
  String highSP = '';

  for (StreetPurokData entry in data) {
    if (entry.cases > maxCases) {
      maxCases = entry.cases;
      sPurok = entry.purok;
    }
  }

  for (StreetPurokData entry in data) {
    if (entry.cases == maxCases) {
      sPurok = entry.purok;
      getHighSP = sPurok;
      highSP = highSP + ' ' + getHighSP;
    }
  }

  return highSP;
}*/
