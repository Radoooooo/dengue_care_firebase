import 'package:firebase_auth/firebase_auth.dart';

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
List<piechartData> pieChartYR3 = [];
double b1 = 0;
double b2 = 0;
double c1 = 0;
double c2 = 0;
double c3 = 0;
double c4 = 0;

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
List<int> listYear = [];
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
        generateMonthP(selectedDateofSymptoms, selectedDateofSymptoms2),
        generateMonthC(selectedDateofSymptoms, selectedDateofSymptoms2),
        generateYearlySeriesWeek(selectedYear, selectedYear2),
        getDataYearRange(selectedYear, selectedYear2),
        //queryAgeGroupsCount(selectedYear),
        queryPatientRecoveredCountYearRange(
            selectedDateofSymptoms, selectedDateofSymptoms2),
        queryPatientAdmittedCountYearRange(
            selectedDateofSymptoms, selectedDateofSymptoms2),
        queryAgeGroupsCountYearRange(
            selectedDateofSymptoms, selectedDateofSymptoms2),
        getPurokCasesYR(selectedDateofSymptoms, selectedDateofSymptoms2),
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
                            setState(() {});
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
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Suspected Cases(Month): ${findMonthWithHighestCasesYMS(selectedDateofSymptoms, selectedDateofSymptoms2)}\nLowest Suspected Cases(Month): ${findMonthWithLowestCasesYMS(selectedDateofSymptoms, selectedDateofSymptoms2)}',
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
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Probable Cases(Month): ${findMonthWithHighestCasesYMP(selectedDateofSymptoms, selectedDateofSymptoms2)}\nLowest Probable Cases(Month): ${findMonthWithLowestCasesYMP(selectedDateofSymptoms, selectedDateofSymptoms2)}',
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
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Confirmed Cases(Month): ${findMonthWithHighestCasesYMC(selectedDateofSymptoms, selectedDateofSymptoms2)}\nLowest Confirmed Cases(Month): ${findMonthWithLowestCasesYMC(selectedDateofSymptoms, selectedDateofSymptoms2)}',
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
                                    text: 'Active Cases Age Group',
                                    textStyle: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                series: <CircularSeries>[
                                  PieSeries<piechartData, String>(
                                    dataSource: pieChartYR3,
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
                                  Text('Child(0-16): ${c1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Young Adult(17-30): ${c2.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Middle Adult(31-45): ${c3.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Old Adult(45 above): ${c4.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        /*Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Analysis: This chart shows the number of active cases per age group\nAge group that have highest cases: {findHighCasesAgeGroup(pieChartYR)}\nAge group that have lowest cases: {findLowCasesAgeGroup(pieChartYR)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )*/
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
                                  Text('Patient Recovered(Yes): ${a1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Patient Recovered(No): ${a2.toInt()}',
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
                                  Text('Patient Admitted(Yes): ${b1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Patient Admitted(No): ${b2.toInt()}',
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
                      child: Column(
                        children: [
                          SizedBox(
                            height: 750,
                            child: SfCartesianChart(
                              //zoomPanBehavior: _zoomPanBehavior,
                              title: ChartTitle(
                                  text:
                                      'Active Cases Per Street/Purok(Suspected, Probable and Confirmed)',
                                  textStyle: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              series: <ChartSeries>[
                                BarSeries<StreetPurokData, String>(
                                  dataSource: barChartYR,
                                  xValueMapper: (StreetPurokData data, _) =>
                                      data.purok,
                                  yValueMapper: (StreetPurokData data, _) =>
                                      data.cases,

                                  //borderWidth: 3,
                                )
                              ],
                              primaryXAxis: CategoryAxis(
                                labelStyle: const TextStyle(fontSize: 10),
                              ),
                              primaryYAxis: NumericAxis(
                                  title: AxisTitle(
                                    text: 'Number Active Cases',
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 10),
                                  ),
                                  interval: 1),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per Street/Purok\nStreet/Purok that have highest cases: ${findHighestCaseSPYR(barChartYR)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      ),
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
    // Populate yearlyData inside the loop
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

Future<List<piechartData>> queryAgeGroupsCountYearRange(
    DateTime dayTime1, dayTime2) async {
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

  QuerySnapshot querySnapshot = await firestore
      .collection('reports')
      .where('age', isLessThanOrEqualTo: childAgeMax)
      .get();

  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      ageGroupCount = ageGroupCount + 1;
    }
  }

  pieChartYR3 = [];
  pieChartYR3.add(piechartData('Child', ageGroupCount, Colors.blue));

  QuerySnapshot querySnapshot2 = await firestore
      .collection('reports')
      .where('age', isGreaterThanOrEqualTo: yAdultAgeMin)
      .where('age', isLessThanOrEqualTo: yAdultAgeMax)
      .get();

  for (var doc in querySnapshot2.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      ageGroupCount2 = ageGroupCount2 + 1;
    }
  }
  pieChartYR3.add(piechartData('Young Adult', ageGroupCount2, Colors.red));

  QuerySnapshot querySnapshot3 = await firestore
      .collection('reports')
      .where('age', isGreaterThanOrEqualTo: mAdultAgeMin)
      .where('age', isLessThanOrEqualTo: mAdultAgeMax)
      .get();

  for (var doc in querySnapshot3.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      ageGroupCount3 = ageGroupCount3 + 1;
    }
  }
  pieChartYR3.add(piechartData('Middle Adult', ageGroupCount3, Colors.green));

  QuerySnapshot querySnapshot4 = await firestore
      .collection('reports')
      .where('age', isGreaterThan: oAdultAgeMin)
      .get();

  for (var doc in querySnapshot4.docs) {
    var data = doc.data() as Map<String, dynamic>;
    DateTime documentDate = data['date'].toDate();
    if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
      ageGroupCount4 = ageGroupCount4 + 1;
    }
  }
  pieChartYR3.add(piechartData('Old Adult', ageGroupCount4, Colors.yellow));

  c1 = ageGroupCount;
  c2 = ageGroupCount2;
  c3 = ageGroupCount3;
  c4 = ageGroupCount4;

  return pieChartYR3;
}

Future<List<StreetPurokData>> getPurokCasesYR(
    DateTime dayTime1, DateTime dayTime2) async {
  try {
    String x = 'purok';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('reports');
    QuerySnapshot querySnapshot = await collection.get();

    Map<String, int> casesByPurok = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime documentDate = data['date'].toDate();
      if (documentDate.isAfter(dayTime1!) && documentDate.isBefore(dayTime2!)) {
        var value = data[x];
        casesByPurok[value] = (casesByPurok[value] ?? 0) + 1;
      }
    }

    barChartYR = [];
    casesByPurok.forEach((x, y) {
      barChartYR.add(StreetPurokData(x, y));
    });
    barChartYR.sort((a, b) => a.cases.compareTo(b.cases));
    return Future.delayed(const Duration(seconds: 1), () {
      return barChartYR;
    });
  } catch (e) {
    print('BarChart Error');
    return Future.value([]);
  }
}

String findMonthWithHighestCasesYMS(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String highM = '';
  String getHighM = '';
  int maxMonth = 0;
  int maxCases = 0;
  int yearV = 0;
  String series1 = '';
  for (LineSeries<DengueData, int> series in yearlySeriesMonthS) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases < data.y) {
          maxCases = data.y;
          maxMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthS) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases == data.y) {
          yearH = series.name;
          maxCases = data.y;
          maxMonth = data.x;
          getHighM = '${getMonthName(maxMonth)}($yearH)';
          highM = '$highM $getHighM,';
        }
      }
    }
  }

  return highM;
}

String findMonthWithLowestCasesYMS(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String lowM = '';
  String getLowM = '';
  int minMonth = 0;
  int minCases = 999999999;
  int yearV = 0;

  String? series1 = '';

  String dayTime1S = dayTime1.year.toString();
  int dayTime1I = int.tryParse(dayTime1S)!;

  String dayTime2S = dayTime2.year.toString();
  int dayTime2I = int.tryParse(dayTime2S)!;

  for (LineSeries<DengueData, int> series in yearlySeriesMonthS) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases > data.y) {
          minCases = data.y;
          minMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthS) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases == data.y) {
          yearH = series.name;
          minCases = data.y;
          minMonth = data.x;
          getLowM = '${getMonthName(minMonth)}($yearH)';
          lowM = '$lowM $getLowM,';
        }
      }
    }
  }

  return lowM;
}

String findMonthWithHighestCasesYMP(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String highM = '';
  String getHighM = '';
  int maxMonth = 0;
  int maxCases = 0;
  int yearV = 0;
  String? series1 = '';
  /*for (LineSeries<DengueData, int> series in yearlySeriesMonthP) {
    String seriesName = series.name.toString();
    yearV = int.tryParse(seriesName.substring(seriesName.length - 4))!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases < data.y) {
          maxCases = data.y;
          maxMonth = data.x;
          yearH = series.name;
        }
      }

      if (maxCases > 0) {
        getHighM = '${getMonthName(maxMonth)}($yearH)';
        if (highM.isNotEmpty) {
          highM += ', ';
        }
        highM += getHighM;
      }
      maxCases = 0;
    }
  }*/
  for (LineSeries<DengueData, int> series in yearlySeriesMonthP) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases < data.y) {
          maxCases = data.y;
          maxMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthP) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases == data.y) {
          yearH = series.name;
          maxCases = data.y;
          maxMonth = data.x;
          getHighM = '${getMonthName(maxMonth)}($yearH)';
          highM = '$highM $getHighM,';
        }
      }
    }
  }

  return highM;
}

String findMonthWithLowestCasesYMP(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String lowM = '';
  String getLowM = '';
  int minMonth = 0;
  int minCases = 999999999;
  int yearV = 0;

  String? series1 = '';

  String dayTime1S = dayTime1.year.toString();
  int dayTime1I = int.tryParse(dayTime1S)!;

  String dayTime2S = dayTime2.year.toString();
  int dayTime2I = int.tryParse(dayTime2S)!;

  for (LineSeries<DengueData, int> series in yearlySeriesMonthP) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases > data.y) {
          minCases = data.y;
          minMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthP) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases == data.y) {
          yearH = series.name;
          minCases = data.y;
          minMonth = data.x;
          getLowM = '${getMonthName(minMonth)}($yearH)';
          lowM = '$lowM $getLowM,';
        }
      }
    }
  }

  return lowM;
}

String findMonthWithHighestCasesYMC(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String highM = '';
  String getHighM = '';
  int maxMonth = 0;
  int maxCases = 0;
  int yearV = 0;
  String series1 = '';

  for (LineSeries<DengueData, int> series in yearlySeriesMonthC) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases < data.y) {
          maxCases = data.y;
          maxMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthC) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1.year && yearV <= dayTime2.year) {
      for (DengueData data in series.dataSource) {
        if (maxCases == data.y) {
          yearH = series.name;
          maxCases = data.y;
          maxMonth = data.x;
          getHighM = '${getMonthName(maxMonth)}($yearH)';
          highM = '$highM $getHighM,';
        }
      }
    }
  }

  return highM;
}

String findMonthWithLowestCasesYMC(DateTime dayTime1, DateTime dayTime2) {
  String? yearH = '';
  String lowM = '';
  String getLowM = '';
  int minMonth = 0;
  int minCases = 999999999;
  int yearV = 0;

  String? series1 = '';

  String dayTime1S = dayTime1.year.toString();
  int dayTime1I = int.tryParse(dayTime1S)!;

  String dayTime2S = dayTime2.year.toString();
  int dayTime2I = int.tryParse(dayTime2S)!;

  for (LineSeries<DengueData, int> series in yearlySeriesMonthC) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases > data.y) {
          minCases = data.y;
          minMonth = data.x;
        }
      }
    }
  }

  for (LineSeries<DengueData, int> series in yearlySeriesMonthC) {
    series1 = series.name.toString();
    series1 = series1.substring(series1.length - 4);
    yearV = int.tryParse(series1)!;

    if (yearV >= dayTime1I && yearV <= dayTime2I) {
      for (DengueData data in series.dataSource) {
        if (minCases == data.y) {
          yearH = series.name;
          minCases = data.y;
          minMonth = data.x;
          getLowM = '${getMonthName(minMonth)}($yearH)';
          lowM = '$lowM $getLowM,';
        }
      }
    }
  }

  return lowM;
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
      highSP = '$highSP $getHighSP,';
    }
  }

  return highSP;
}
