import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

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
    firebaseService.initialize();
    firebaseService.addLedStateListener((ledState) {
      setState(() {
        _ledState = int.parse(ledState);
      });
    });
    firebaseService.addPhotoresistorStateListener((photoresistorState) {
      setState(() {
        _photoresistorState = int.parse(photoresistorState);
      });
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
          YourWidget(states: states, handleSwitchClick: handleSwitchClick)
        ],
      ),
    );
  }
}

class YourWidget extends StatelessWidget {
  final List<Map<String, dynamic>> states;
  final Function(Map<String, dynamic>) handleSwitchClick;

  const YourWidget(
      {super.key, required this.states, required this.handleSwitchClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        return ListTile(
          leading: Icon(
            state['icon'],
            color: state['state'] == 1 ? Colors.green : null,
          ),
          title: Text(
              '${state['name']} State: ${state['state'] == -1 ? '...' : state['state'] == 1 ? 'On' : 'Off'}'),
          trailing: Switch(
            value: state['state'] == 1,
            onChanged: (bool value) {
              handleSwitchClick(state);
            },
          ),
        );
      },
    );
  }
}
