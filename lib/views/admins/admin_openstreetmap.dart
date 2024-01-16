import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/widgets/real_timedatetime.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

final mapController = MapController();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class AdminOpenStreetMap extends StatefulWidget {
  const AdminOpenStreetMap({super.key});

  @override
  State<AdminOpenStreetMap> createState() => _AdminOpenStreetMapState();
}

class _AdminOpenStreetMapState extends State<AdminOpenStreetMap> {
  late Map<String, LatLng> purokList = {};
  int purokCounter = 0;
  String selectPurok = '';
  int? len;
  int? suspectedCount;
  int? probableCount;
  int? confirmedCount;
  int? suslen;
  int? problen;
  int? conflen;
  int forMap = 0;
  List<WeightedLatLng> weightedLatLngList = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;

  void convertToWeightedLatLng(
      Map<String, LatLng>? purokList, List<WeightedLatLng> weightedLatLngList) {
    purokList?.forEach((purok, latLng) async {
      // Get the case count for the current Purok
      int caseCount = await getCountForPurok(purok);

      // Calculate intensity based on case count
      double intensity =
          caseCount.toDouble() * 30.0; //!?adjust multiplier as needed

      weightedLatLngList.add(WeightedLatLng(latLng, intensity));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPurokData();
    fetchData();
  }

  //! For Map Purok Data
  Future<Map<String, LatLng>> fetchPurokData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('reports')
              .where('patient_recovered', isEqualTo: 'No')
              .get();

      return Map.fromEntries(querySnapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> document) {
        final purok = document['purok'];
        final latitude = document['latitude'];
        final longitude = document['longitude'];
        final coordinates = LatLng(latitude, longitude);

        return MapEntry(purok, coordinates);
      }));
    } catch (e) {
      print('Error fetching data: $e');
      rethrow; // You might want to handle errors differently based on your use case
    }
  }

  Future<void> fetchData() async {
    try {
      final result = await fetchPurokData();
      if (result != null) {
        Map<String, LatLng> dataMap = result;

        setState(() {
          purokList = dataMap;
          convertToWeightedLatLng(purokList, weightedLatLngList);
        });

        // Now you can use dataMap and uniquePurokCount as needed
        print('Data Map: $dataMap');
        fetchDataForSelectedPurok();
      } else {
        // Handle the case where data is null
        print('Fetched data is null');
      }
    } catch (e) {
      // Handle errors
      print('Error fetching data: $e');
    }
  }

  //!Individual Purok Data
  Future<int> getCountForPurok(String selectedPurok) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('reports')
              .where('purok', isEqualTo: selectedPurok)
              .where('patient_recovered', isEqualTo: 'No')
              .get();
      int size = querySnapshot.size;

      QuerySnapshot<Map<String, dynamic>> querySus = await FirebaseFirestore
          .instance
          .collection('reports')
          .where('purok', isEqualTo: selectedPurok)
          .where('status', isEqualTo: 'Suspected')
          .where('patient_recovered', isEqualTo: 'No')
          .get();

      int susSize = querySus.size;

      QuerySnapshot<Map<String, dynamic>> queryProb = await FirebaseFirestore
          .instance
          .collection('reports')
          .where('purok', isEqualTo: selectedPurok)
          .where('status', isEqualTo: 'Probable')
          .where('patient_recovered', isEqualTo: 'No')
          .get();

      int probSize = queryProb.size;

      QuerySnapshot<Map<String, dynamic>> queryConf = await FirebaseFirestore
          .instance
          .collection('reports')
          .where('purok', isEqualTo: selectedPurok)
          .where('status', isEqualTo: 'Confirmed')
          .where('patient_recovered', isEqualTo: 'No')
          .get();

      int confSize = queryConf.size;

      setState(() {
        size = querySnapshot.size;
        len = size;
        forMap = size;

        susSize = querySus.size;
        suslen = susSize;

        probSize = queryProb.size;
        problen = probSize;

        confSize = queryConf.size;
        conflen = confSize;
      });
      return size;
    } catch (e) {
      // Handle any potential errors, e.g., network issues or Firestore exceptions
      print('Error getting count: $e');
      return -1; // Return a special value to indicate an error
    }
  }

  Future<void> fetchDataForSelectedPurok() async {
    //!! NEW CODE
    List<Future<int>> futures = [];

    for (var purok in purokList.keys) {
      futures.add(getCountForPurok(purok));
    }

    List<int> results = await Future.wait(futures);

    // Now results contains the count for each purok
    // Update the UI or handle the data as needed
    for (int i = 0; i < purokList.length; i++) {
      print('Count for ${purokList.keys.elementAt(i)}: ${results[i]}');
    }
  }

  void _showDialog(BuildContext context, LatLng point, String purokName) async {
    int fetchedData = await getCountForPurok(purokName);

    if (fetchedData != -1) {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Details',
              style: GoogleFonts.poppins(fontSize: 24),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const RealTimeDateTime(),
                Text(
                  'Case Reported: $len',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Purok: $purokName ',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Suspected Cases: $suslen',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Text(
                  'Probable Cases: $problen',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                Text(
                  'Confirmed Cases: $conflen',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Error getting count for $purokName');
    }
  }

  // HeatmapLayerOptions heatmapLayerOptions = HeatmapLayerOptions(
  //   radius: 25.0,
  //   gradientColors: [
  //     Colors.green,
  //     Colors.yellow,
  //     Colors.orange,
  //     Colors.red,
  //   ],
  // );

  // HeatmapLayer heatmapLayer = HeatmapLayer(
  //   options: heatmapLayerOptions,
  //   points: purokList.values.toList(),
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FlutterMap(
        mapController: mapController,
        options: const MapOptions(
          initialCenter: LatLng(7.1090628857797755, 125.61323257408277),
          initialZoom: 14.0,
          maxZoom: 18.0,
          minZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),

          //! Marker Layer was here!
          MarkerLayer(
            markers: purokList.entries.map((entry) {
              return Marker(
                child: GestureDetector(
                  onTap: () {
                    _showDialog(context, entry.value, entry.key);
                    getCountForPurok(entry.key);
                    setState(() {
                      selectPurok = entry.key;
                    });
                  },
                  child: const Icon(
                    Icons.circle,
                    color: Colors.transparent,
                    size: 20,
                  ),
                ),
                width: 40.0,
                height: 40.0,
                point: entry.value,
              );
            }).toList(),
          ),

          if (weightedLatLngList.isNotEmpty)
            HeatMapLayer(
              heatMapDataSource:
                  InMemoryHeatMapDataSource(data: weightedLatLngList),
              heatMapOptions: HeatMapOptions(
                minOpacity: 0.1,
                radius: 90,
              ),
            ),
          if (weightedLatLngList.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
























//? MarkerLayer
//  MarkerLayer(
//             markers: purokList.entries.map((entry) {
//               return Marker(
//                 child: GestureDetector(
//                   onTap: () {
//                     _showDialog(context, entry.value, entry.key);
//                     getCountForPurok(entry.key);
//                     setState(() {
//                       selectPurok = entry.key;
//                     });
//                   },
//                   child: Icon(
//                     Icons.circle,
//                     color: Colors.red[400],
//                   ),
//                 ),
//                 width: 40.0,
//                 height: 40.0,
//                 point: entry.value,
//               );
//             }).toList(),
//           )