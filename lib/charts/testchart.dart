import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

List<DengueData> chart = [];
List<DengueData> chart2 = [];
List<DengueData> chart3 = [];
List<DengueData> yearlyData = [];
List<LineSeries<DengueData, int>> yearlySeries = [];
List<piechartData> pieChart = [];

List<StreetPurokData> barChart = [];
List<int> listYear = [];

int selectedYear = DateTime.now().year;
double minYear = 0;
double maxYear = 0;

double a1 = 0;
double a2 = 0;
double a3 = 0;
double a4 = 0;

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
  piechartData(this.ageGroup, this.number, this.color);
  String ageGroup;
  double number;
  Color color;
}

class StreetPurokData {
  StreetPurokData(this.purok, this.cases);
  String purok;
  int cases;
}

class testChart extends StatefulWidget {
  const testChart({super.key});

  @override
  State<testChart> createState() => _testChartState();
}

class _testChartState extends State<testChart> {
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
        queryAgeGroupsCount(selectedYear),
        getPurokCases(selectedYear),
      ]),
      builder: (context, snapshot) {
        if (chart.isNotEmpty) {
          barChart.sort((a, b) => a.cases.compareTo(b.cases));

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
                        Text('Sort by: ',
                            style: GoogleFonts.poppins(fontSize: 20)),
                        DropdownButton<int>(
                          value: selectedYear,
                          items: listYear.map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString(),
                                  style: GoogleFonts.poppins(fontSize: 20)),
                            );
                          }).toList(),
                          onChanged: (newValue) async {
                            setState(() {
                              selectedYear = newValue!;

                              if (selectedYear == newValue) {
                                return;
                              } else {
                                getYearlyDataMonth(selectedYear).then((result) {
                                  chart = result;
                                });
                                getYearlyDataWeek(selectedYear).then((result) {
                                  chart2 = result;
                                });
                                queryAgeGroupsCount(selectedYear)
                                    .then((result) {
                                  pieChart = result;
                                });
                                getPurokCases(selectedYear).then((result) {
                                  barChart = result;
                                });
                              }
                            });
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            setState(() {
                              chart = [];
                              chart2 = [];
                              chart3 = [];
                              barChart = [];
                              pieChart = [];
                              yearlyData = [];
                              yearlySeries = [];

                              a1 = 0;
                              a2 = 0;
                              a3 = 0;
                              a4 = 0;
                            });
                            showLoadingDialog();
                            await deleteAllDocumentsInCollection(
                                'denguelinelist');
                            dismissLoadingDialog();
                          },
                          child: Text('Clear Data',
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
                                text: "Monthly Active Cases",
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
                            series: <ChartSeries>[
                              LineSeries<DengueData, int>(
                                  dataSource: chart,
                                  xValueMapper: (DengueData data, _) => data.x,
                                  yValueMapper: (DengueData data, _) => data.y,
                                  name: 'Active Cases',
                                  markerSettings:
                                      const MarkerSettings(isVisible: true)),
                            ],
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per month for the selected year.\nHighest Active Cases(Month): ${findMonthWithHighestCases(chart)}\nLowest Active Cases(Month): ${findMonthWithLowestCases(chart)}',
                                style: TextStyle(fontSize: 16),
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
                                text: "Weekly Active Cases",
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Week",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                minimum: 0,
                                maximum: 48,
                                interval: 1),
                            primaryYAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Number of Active Cases",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20))),
                            tooltipBehavior: _tooltipBehavior2,
                            series: <ChartSeries>[
                              LineSeries<DengueData, int>(
                                  dataSource: chart2,
                                  xValueMapper: (DengueData data, _) => data.x,
                                  yValueMapper: (DengueData data, _) => data.y,
                                  name: 'Active Cases',
                                  markerSettings:
                                      const MarkerSettings(isVisible: true)),
                            ],
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per week for the selected year.\nHighest Active Cases(Week): ${findHighestCase(chart2)}\nLowest Active Cases(Week): ${findLowestCase(chart2)}',
                                style: TextStyle(fontSize: 16),
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
                                text: "Yearly Morbidity",
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Year",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                minimum: minYear,
                                maximum: maxYear,
                                interval: 1),
                            primaryYAxis: NumericAxis(
                                title: AxisTitle(
                                    text: "Number of Active Cases",
                                    textStyle:
                                        GoogleFonts.poppins(fontSize: 20)),
                                interval: 1),
                            tooltipBehavior: _tooltipBehavior3,
                            series: <ChartSeries>[
                              LineSeries<DengueData, int>(
                                  dataSource: chart3,
                                  xValueMapper: (DengueData data, _) => data.x,
                                  yValueMapper: (DengueData data, _) => data.y,
                                  name: 'Active Cases',
                                  markerSettings:
                                      const MarkerSettings(isVisible: true)),
                            ],
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per year.\nHighest Active Cases(Year): ${findHighestCase(chart3)}\nLowest Active Cases(Year): ${findLowestCase(chart3)}',
                                style: TextStyle(fontSize: 16),
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
                              text: "Monthly Morbidity - Multiple Years",
                              textStyle: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            enableAxisAnimation: true,
                            primaryXAxis: NumericAxis(
                              title: AxisTitle(
                                text: "Month",
                                textStyle: GoogleFonts.poppins(fontSize: 20),
                              ),
                              minimum: 0,
                              maximum: 12,
                              interval: 1,
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                text: "Number of Active Cases",
                                textStyle: GoogleFonts.poppins(fontSize: 20),
                              ),
                            ),
                            tooltipBehavior: _tooltipBehavior4,
                            series: yearlySeries,
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Analysis: This chart shows the number of active cases per year\nMonths that has same active cases(Recurring): ${findMonthsWithSameCases(yearlySeries)}',
                                style: TextStyle(fontSize: 16),
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
                                    dataSource: pieChart,
                                    pointColorMapper: (piechartData data, _) =>
                                        data.color,
                                    xValueMapper: (piechartData data, _) =>
                                        data.ageGroup,
                                    yValueMapper: (piechartData data, _) =>
                                        data.number,
                                    dataLabelMapper: (piechartData data, _) =>
                                        '${data.ageGroup}:${data.number}',
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
                                  Text('Child(0-16): ${a1.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Young Adult(17-30): ${a2.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Middle Adult(31-45): ${a3.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                  Text('Old Adult(45 above): ${a4.toInt()}',
                                      style: GoogleFonts.poppins(fontSize: 20)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Analysis: This chart shows the number of active cases per age group\nAge group that have highest cases: ${findHighCasesAgeGroup(pieChart)}\nAge group that have highest cases: ${findLowCasesAgeGroup(pieChart)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
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
                                  text: 'Active Cases Per Street/Purok',
                                  textStyle: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              series: <ChartSeries>[
                                BarSeries<StreetPurokData, String>(
                                  dataSource: barChart,
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
                                      text: 'Number of Active Cases',
                                      textStyle:
                                          GoogleFonts.poppins(fontSize: 20)),
                                  interval: 1),
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
  try {
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
  } catch (e) {
    return Future.value([]);
  }
}

Future<List<int>> getListYear() async {
  try {
    String x = 'Year';
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection('denguelinelist')
        .orderBy('Year', descending: false)
        .get();

    Set<int> uniqueValues = {};
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x)) {
        uniqueValues.add(data[x]);
      }
    }
    listYear = uniqueValues.toList();

    return listYear;
  } catch (e) {
    print('Error: $e');
    return Future.value([]);
  }
}

Future<List<DengueData>> getYearlyDataMonth(int year) async {
  try {
    String x = 'MorbidityMonth';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot =
        await collection.orderBy('MorbidityMonth', descending: false).get();

    Map<int, int> valueL = {};

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(x) && data['Year'] == year) {
        var value = data[x];
        valueL[value] = (valueL[value] ?? 0) + 1;
      }
    }

    chart = [];
    Map<int, int> counts = valueL;

    counts.forEach((x, y) {
      chart.add(DengueData(x, y));
    });

    return Future.delayed(const Duration(seconds: 1), () {
      return chart;
    });
  } catch (e) {
    print('Empty Chart');
    return Future.value([]);
  }
}

Future<List<DengueData>> getYearlyDataWeek(int year) async {
  try {
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

    chart2 = [];
    Map<int, int> counts = valueL;
    counts.forEach((x, y) {
      chart2.add(DengueData(x, y));
    });

    return Future.delayed(const Duration(seconds: 1), () {
      return chart2;
    });
  } catch (e) {
    print('Empty Chart2');
    return Future.value([]);
  }
}

Future<List<DengueData>> getDataYear() async {
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

    chart3 = [];
    Map<int, int> counts = valueL;
    counts.forEach((x, y) {
      chart3.add(DengueData(x, y));
    });

    return chart3;
  } catch (e) {
    print('Empty Chart3');
    return Future.value([]);
  }
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
    print('Empty BarChart');
    return Future.value([]);
  }
}

Future<void> deleteAllDocumentsInCollection(String collectionPath) async {
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final QuerySnapshot querySnapshot =
        await firestore.collection(collectionPath).get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (final document in documents) {
      await document.reference.delete();
    }
    logAdminAction('Clear Data', user!.uid);
    print(
        'All documents in the collection "$collectionPath" have been deleted.');
  } catch (e) {
    print('Error deleting documents: $e');
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

Future<List<ChartSeries<DengueData, int>>> generateYearlySeries() async {
  yearlySeries = [];
  List<int> listYear = await getListYear();

  for (int year in listYear) {
    String x = 'MorbidityMonth';
    CollectionReference collection =
        FirebaseFirestore.instance.collection('denguelinelist');
    QuerySnapshot querySnapshot =
        await collection.orderBy('MorbidityMonth', descending: false).get();

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
    yearlySeries.add(LineSeries<DengueData, int>(
      dataSource: yearlyData,
      xValueMapper: (DengueData data, _) => data.x,
      yValueMapper: (DengueData data, _) => data.y,
      name: 'Year: $year',
      markerSettings: const MarkerSettings(isVisible: true),
    ));
  }

  return yearlySeries;
}

String findMonthWithHighestCases(List<DengueData> data) {
  String highM = '';
  String getHighM = '';
  int maxCases = 0;
  int maxMonth = 0;

  for (DengueData entry in data) {
    if (entry.y > maxCases) {
      maxCases = entry.y;
      maxMonth = entry.x;
      //getHighM = getMonthName(maxMonth);
      //highM = highM + ' ' + getHighM;
    }
  }

  for (DengueData entry in data) {
    if (entry.y == maxCases) {
      maxCases = entry.y;
      maxMonth = entry.x;
      getHighM = getMonthName(maxMonth);
      highM = highM + ' ' + getHighM;
    }
  }

  return highM;
}

String findMonthWithLowestCases(List<DengueData> data) {
  String lowM = '';
  String getLowM = '';
  int minCases = data[0].y; // Set it to the maximum possible value initially
  int minMonth = 0;

  for (DengueData entry in data) {
    if (entry.y < minCases) {
      minCases = entry.y;
      minMonth = entry.x;
    }
  }

  for (DengueData entry in data) {
    if (entry.y == minCases) {
      minCases = entry.y;
      minMonth = entry.x;
      getLowM = getMonthName(minMonth);
      lowM = lowM + ' ' + getLowM;
    }
  }

  return lowM;
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

String findHighestCase(List<DengueData> data) {
  String getHighW = '';
  int maxWeek = 0;
  int maxCases = 0;
  String highW = '';

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

String findLowestCase(List<DengueData> data) {
  String getLowW = '';
  int minWeek = 0;
  int minCases = data[0].y;
  String lowW = '';

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

List<String> findMonthsWithSameCases(
    List<ChartSeries<DengueData, int>> yearlySeries) {
  List<String> monthsWithSameCases = [];

  // Combine data from all years into a single list
  List<DengueData> combinedData = [];
  for (var series in yearlySeries) {
    combinedData.addAll(series.dataSource as Iterable<DengueData>);
  }

  // Create a map to store counts for each month
  Map<int, List<int>> countsByMonth = {};

  // Populate the map
  for (var data in combinedData) {
    if (!countsByMonth.containsKey(data.x)) {
      countsByMonth[data.x] = [];
    }
    countsByMonth[data.x]!.add(data.y);
  }
  print(countsByMonth);
  // Find months with the same number of active cases
  countsByMonth.forEach((month, counts) {
    print(counts.toSet().length);
    if (counts.toSet().length == 1 && counts.length == listYear.length) {
      // All counts for this month are the same
      monthsWithSameCases.add(getMonthName(month));
    }
  });

  return monthsWithSameCases;
}

String findHighCasesAgeGroup(List<piechartData> data) {
  double Cases = 0;
  String getAgeGroup = '';
  String hAgeGroup = '';

  String ageGroup = '';
  for (piechartData entry in data) {
    if (entry.number > Cases) {
      Cases = entry.number;
      ageGroup = entry.ageGroup;
    }
  }

  for (piechartData entry in data) {
    if (entry.number == Cases) {
      Cases = entry.number;
      ageGroup = entry.ageGroup;
      getAgeGroup = ageGroup;
      hAgeGroup = hAgeGroup + ' ' + getAgeGroup;
    }
  }

  return ageGroup;
}

String findLowCasesAgeGroup(List<piechartData> data) {
  double Cases = data[0].number;

  String getAgeGroup = '';
  String lAgeGroup = '';

  String ageGroup = '';
  for (piechartData entry in data) {
    if (entry.number <= Cases) {
      Cases = entry.number;
      ageGroup = entry.ageGroup;
    }
  }

  for (piechartData entry in data) {
    if (entry.number == Cases) {
      Cases = entry.number;
      ageGroup = entry.ageGroup;
      getAgeGroup = ageGroup;
      lAgeGroup = lAgeGroup + ' ' + getAgeGroup;
    }
  }

  return ageGroup;
}

Widget _gap() => const SizedBox(height: 8);
