import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/lock_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late FirebaseService firebaseService;
  final userId = "demo-user";
  List<Map<String, dynamic>> lockItems = [];

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    firebaseService.getLocks(userId).then((locks) {
      setState(() {
        lockItems = locks;
      });

      for (var lock in locks) {
        addLockStateListener(lock['id']);
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

  @override
  Widget build(BuildContext context) {
    void handleButtonClick(Map<String, dynamic> lockItem) async {
      String newStatus =
          lockItem['status'] == 'locked' ? 'unlocking' : 'locking';
      setState(() {
        lockItem['status'] = newStatus;
      });
      await firebaseService.writeData(
          "locks/${lockItem['id']}/status", newStatus);
    }

    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: LockList(
                  lockItems: lockItems, handleButtonClick: handleButtonClick))
        ],
      ),
    );
  }
}
