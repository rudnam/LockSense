import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locksense/pages/dashboard_page.dart';
import 'package:locksense/pages/info_page.dart';
import 'package:locksense/pages/notification_page.dart';
import 'package:locksense/services/auth_service.dart';
import 'package:locksense/services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseService firebaseService;
  var currentPageIndex = 0;
  // final user = FirebaseAuth.instance.currentUser;
  final user = {"uid": "demo-user", "displayName": "Demo User"};
  List<Map<String, dynamic>> lockItems = [];
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    firebaseService.getLocks(user['uid']!).then((locks) {
      setState(() {
        lockItems = locks;
      });

      for (var lock in locks) {
        addLockStateListener(lock['id']);
      }
    });

    firebaseService.addNotificationListener(user['uid']!, (notifs) {
      if (mounted) {
        setState(() {
          notifications = notifs ?? [];
        });
      }
    });
  }

  void addLockStateListener(String lockId) {
    firebaseService.addLockStatusListener(lockId, (lockStatus) {
      if (mounted) {
        setState(() {
          final lockItem = lockItems.firstWhere((lock) => lock['id'] == lockId,
              orElse: () => {});
          if (lockItem['status'] == 'unlocking' && lockStatus == 'locked') {
            _showSnackbar("Unlock attempt failed.");
          } else if (lockItem['status'] == 'locking' &&
              lockStatus == 'unlocked') {
            _showSnackbar("Lock attempt failed.");
          }
          lockItem['status'] = lockStatus;
        });
      }
    });
  }

  void _showSnackbar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void handleLockButtonClick(Map<String, dynamic> lockItem) async {
    String newStatus = lockItem['status'] == 'locked' ? 'unlocking' : 'locking';
    setState(() {
      lockItem['status'] = newStatus;
    });
    await firebaseService.writeData(
        "locks/${lockItem['id']}/status", newStatus);
  }

  void clearNotifications() async {
    setState(() {});
    await firebaseService.clearNotifications(user['uid']!);
    setState(() {
      notifications = [];
    });
  }

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
        page = DashboardPage(
            lockItems: lockItems, handleLockButtonClick: handleLockButtonClick);
      case 2:
        page = NotificationPage(
          notifications: notifications,
          clearNotifications: clearNotifications,
        );
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
