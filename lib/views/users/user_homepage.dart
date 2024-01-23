import 'package:denguecare_firebase/views/users/user_dengueheatmap.dart';
import 'package:denguecare_firebase/views/users/user_report_page_menu.dart';
import 'package:denguecare_firebase/views/users/user_settings_page.dart';
import 'package:denguecare_firebase/views/widgets/post_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PostsList(),
    );
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
}

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Calling the Future function when the page loads.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int currentIndex = 0;
  final screens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DengueCare',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.home_rounded),
              text: 'Home',
            ),
            Tab(
              icon: Icon(Icons.map_rounded),
              text: 'Map',
            ),
            Tab(
              icon: Icon(Icons.report_rounded),
              text: 'Reports',
            ),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserHomePage(),
          UserDengueHeatMapPage(),
          UserReportPageMenu(),
          UserSettingsPage(),
        ],
      ),
    );
  }
}
