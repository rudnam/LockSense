import 'package:flutter/material.dart';

class StateList extends StatelessWidget {
  final List<Map<String, dynamic>> states;
  final Function(Map<String, dynamic>) handleButtonClick;

  const StateList(
      {super.key, required this.states, required this.handleButtonClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: states.length,
      itemBuilder: (context, index) {
        final state = states[index];
        return ListTile(
          leading: Icon(
            state['state'] == "locked" || state['state'] == "unlocking"
                ? Icons.lock
                : Icons.lock_open,
            color: Colors.green,
          ),
          title: Text('${state['name']} State: ${state['state']}'),
          trailing: SizedBox(
            width: 80,
            child: state['state'] == 'locking' || state['state'] == 'unlocking'
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Center(
                    child: TextButton(
                      onPressed: (state['state'] == 'locked' ||
                              state['state'] == 'unlocked')
                          ? () {
                              handleButtonClick(state);
                            }
                          : null,
                      child: Text(
                        state['state'] == 'locked' ? 'Unlock' : 'Lock',
                        style: TextStyle(
                          color: (state['state'] == 'locked' ||
                                  state['state'] == 'unlocked')
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
