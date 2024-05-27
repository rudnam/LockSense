import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locksense/pages/dashboard_page.dart';
import 'package:locksense/pages/info_page.dart';
import 'package:locksense/pages/notification_page.dart';
import 'package:locksense/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentPageIndex = 0;
  final user = FirebaseAuth.instance.currentUser;

  void signUserOut() {
    AuthService().signOutWithGoogle();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = const InfoPage();
      case 1:
        page = const DashboardPage();
      case 2:
        page = const NotificationPage();
      default:
        throw UnimplementedError('no widget for $currentPageIndex');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('LockSense'),
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: page,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.dashboard),
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
