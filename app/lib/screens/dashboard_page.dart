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
  late int _ledState = -1;
  late int _photoresistorState = -1;

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    firebaseService.addLedStateListener((ledState) {
      if (mounted) {
        setState(() {
          _ledState = int.parse(ledState);
        });
      }
    });
    firebaseService.addPhotoresistorStateListener((photoresistorState) {
      if (mounted) {
        setState(() {
          _photoresistorState = int.parse(photoresistorState);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> states = [
      {
        'name': 'Led',
        'dbPath': 'led/state',
        'state': _ledState,
        'icon': Icons.lightbulb
      },
      {
        'name': 'Photoresistor',
        'dbPath': 'photoresistor/state',
        'state': _photoresistorState,
        'icon': Icons.cable
      },
    ];

    void handleSwitchClick(Map<String, dynamic> state) async {
      int newState = state['state'] == 0 ? 1 : 0;
      await firebaseService.writeData(state['dbPath'], newState);
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
                  states: states, handleSwitchClick: handleSwitchClick))
        ],
      ),
    );
  }
}
