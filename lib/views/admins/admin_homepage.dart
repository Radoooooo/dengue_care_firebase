import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/charts/testchart.dart';
import 'package:denguecare_firebase/views/admins/admin_accountsettings.dart';
import 'package:denguecare_firebase/views/admins/admin_announcements.dart';
import 'package:denguecare_firebase/views/admins/admin_manageadmin.dart';
import 'package:denguecare_firebase/views/admins/admin_openstreetmap.dart';
import 'package:denguecare_firebase/views/admins/admin_postpage.dart';
import 'package:denguecare_firebase/views/admins/admin_settingspage.dart';
import 'package:denguecare_firebase/views/widgets/post_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page.dart';
import 'admin_dataviz.dart';
import 'admin_reportpage.dart';
import 'package:denguecare_firebase/views/admins/admin_logs.dart';

String? role;

showLogoutConfirmationDialog(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled logout
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const LoginPage()); // User confirmed logout
              logAdminAction('LOG OUT', user!.uid);
            },
            child: const Text("Logout"),
          ),
        ],
      );
    },
  );
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

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  Animation<double>? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: const PostsList(),
        floatingActionButton: FloatingActionBubble(
          items: <Bubble>[
            Bubble(
              title: "Create Post",
              iconColor: Colors.white,
              bubbleColor: Colors.green,
              icon: Icons.add_box,
              titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                // _animationController!.reverse();
                Get.offAll(() => const AdminPostPage());
              },
            ),
            Bubble(
              title: "Create Announcements",
              iconColor: Colors.white,
              bubbleColor: Colors.green,
              icon: Icons.announcement,
              titleStyle:
                  GoogleFonts.poppins(fontSize: 16, color: Colors.white),
              onPress: () {
                // _animationController!.reverse();
                Get.offAll(() => const AdminAnnouncementPage());
              },
            ),
          ],
          animation: _animation!,
          onPress: () => _animationController!.isCompleted
              ? _animationController!.reverse()
              : _animationController!.forward(),
          backGroundColor: Colors.green,
          iconColor: Colors.white,
          iconData: Icons.menu,
        ),
      ),
    );
  }
}

//! MAIN PAGEEEE

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage>
    with SingleTickerProviderStateMixin {
  Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (documentSnapshot.exists) {
      return documentSnapshot.get('role') as String?;
    } else {
      // ignore: use_build_context_synchronously
      _showSnackbarError(context, 'Document does not exist on the database');
      return null;
    }
  }

  Future<String?> checkUserRole() async {
    role = await getUserRole();
    if (role != null) {
      print("User Role: $role");
      return role;
    }
    return null;
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

  Text? textForAdmin(String role) {
    if (role == "Admin") {
      return const Text(
        'Welcome Admin',
        style: TextStyle(fontSize: 24, color: Colors.white),
      );
    } else if (role == "superadmin") {
      return const Text(
        'Welcome Superadmin!',
        style: TextStyle(fontSize: 24, color: Colors.white),
      );
    }

    return null;
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    checkUserRole();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'DengueCare',
            style: GoogleFonts.poppins(),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontSize: 12),
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.home_rounded),
                text: 'Home',
              ),
              Tab(
                text: 'Reports',
                icon: badges.Badge(
                  badgeContent: LengthIndicator(),
                  child: Icon(Icons.report_rounded),
                ),
              ),
              Tab(
                icon: Icon(Icons.map_rounded),
                text: 'Map',
              ),
              Tab(
                icon: Icon(Icons.auto_graph_rounded),
                text: 'Data\nAnalytics',
              ),
            ],
          ),
        ),
        drawer: FutureBuilder<String?>(
          future: checkUserRole(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data != null) {
                return Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                        ),
                        child: Text(
                          'Welcome $role',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Account Settings',
                          style: GoogleFonts.poppins(),
                        ),
                        leading: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Get.offAll(() => const AdminAccountSettings());
                        },
                      ),
                      Visibility(
                        visible: role == 'superadmin',
                        child: ListTile(
                          title: Text(
                            'Manage Admins',
                            style: GoogleFonts.poppins(),
                          ),
                          leading: const Icon(
                            Icons.person_pin_rounded,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Get.offAll(() => const ManageAdmin());
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'View Logs',
                          style: GoogleFonts.poppins(),
                        ),
                        leading: const Icon(
                          Icons.view_list_outlined,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Get.offAll(() => const adminLogs());
                        },
                      ),
                      Visibility(
                        visible: role == 'superadmin',
                        child: ListTile(
                          title: Text(
                            'Settings',
                            style: GoogleFonts.poppins(),
                          ),
                          leading: const Icon(
                            Icons.settings,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Get.offAll(() => const AdminSettingsPage());
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                        ),
                        onTap: () {
                          showLogoutConfirmationDialog(context);
                        },
                      ),
                    ],
                  ),
                );
              }
              // You can also handle the null case differently, like showing a different message or a loader.
              return const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text('Fetching user role...'),
              );
            } else {
              // This can be a loader or some placeholder till the role is fetched.
              return const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text('Loading...'),
              );
            }
          },
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            AdminHomePage(),
            AdminReportPage(),
            AdminOpenStreetMap(),
            AdminDataVizPage(),
          ],
        ),
      ),
    );
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
