import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/lock_list.dart';

class DashboardPage extends StatefulWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> lockItems;
  final Function(Map<String, dynamic>) handleLockIconClick;
  final Function(Map<String, dynamic>) handleLockButtonClick;

  const DashboardPage({
    super.key,
    required this.isLoading,
    required this.lockItems,
    required this.handleLockIconClick,
    required this.handleLockButtonClick,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late FirebaseService firebaseService;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  isLoading: widget.isLoading,
                  lockItems: widget.lockItems,
                  handleIconClick: widget.handleLockIconClick,
                  handleButtonClick: widget.handleLockButtonClick))
        ],
      ),
    );
  }
}
