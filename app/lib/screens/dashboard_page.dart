import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/state_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late FirebaseService firebaseService;
  final userId = "demo-user";
  final lockId = "-NycrH2cYavPQDTVmfKp";
  List<Map<String, dynamic>> states = [];

  late String _lockState = "...";

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    firebaseService.addLockStateListener(lockId, (lockState) {
      if (mounted) {
        setState(() {
          _lockState = lockState;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> lockStates = [
      {
        'name': 'Lock 1',
        'id': lockId,
        'ownerUID': 'demo-user',
        'state': _lockState,
      },
    ];

    void handleButtonClick(Map<String, dynamic> state) async {
      String newState = state['state'] == 'locked' ? 'unlocking' : 'locking';
      setState(() {
        state['state'] = newState;
      });
      await firebaseService.writeData("locks/${state['id']}/state", newState);
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
              child: StateList(
                  states: lockStates, handleButtonClick: handleButtonClick))
        ],
      ),
    );
  }
}
