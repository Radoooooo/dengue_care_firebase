import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denguecare_firebase/views/admins/admin_accountsettings.dart';
import 'package:denguecare_firebase/views/admins/admin_announcements.dart';
import 'package:denguecare_firebase/views/admins/admin_manageadmin.dart';
import 'package:denguecare_firebase/views/admins/admin_openstreetmap.dart';
import 'package:denguecare_firebase/views/admins/admin_postpage.dart';
import 'package:denguecare_firebase/views/widgets/post_list.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
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

class _AdminHomePageState extends State<AdminHomePage> {
  static const _actionTitles = [
    'Edit Posts',
    'Create announcement',
    'Add new post',
  ];
  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: const PostsList(),
        floatingActionButton: ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: () => _showAction(context, 0),
              icon: const Icon(Icons.edit),
            ),
            ActionButton(
              onPressed: () {
                Get.offAll(() => const AdminAnnouncementPage());
              },
              icon: const Icon(Icons.announcement),
            ),
            ActionButton(
              onPressed: () {
                Get.offAll(() => const AdminPostPage());
              },
              icon: const Icon(Icons.add_box),
            ),
          ],
        ),
      ),
    );
  }

  // void listenToPosts() {
  //   FirebaseFirestore.instance.collection('posts').snapshots().listen(
  //       (snapshot) {
  //     List<DocumentSnapshot> documents = snapshot.docs;
  //     for (DocumentSnapshot doc in documents) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       print(data);
  //     }
  //   }, onError: (e) {
  //     Utils.showSnackBar(e.toString());
  //   });
  // }
}

void handleClick(int item) {
  switch (item) {
    case 0:
      break;
    case 1:
      break;
    case 2:
      break;
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "btn1",
            onPressed: _toggle,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    super.key,
    required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      height: isBig ? 128 : 36,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.grey.shade300,
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
    Text? widget;

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
