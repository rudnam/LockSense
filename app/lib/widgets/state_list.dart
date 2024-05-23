import 'package:flutter/material.dart';

class StateList extends StatelessWidget {
  final List<Map<String, dynamic>> states;
  final Function(Map<String, dynamic>) handleSwitchClick;

  const StateList(
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
