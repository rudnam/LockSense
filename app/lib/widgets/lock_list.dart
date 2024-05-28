import 'package:flutter/material.dart';

class LockList extends StatelessWidget {
  final List<Map<String, dynamic>> lockItems;
  final Function(Map<String, dynamic>) handleButtonClick;

  const LockList(
      {super.key, required this.lockItems, required this.handleButtonClick});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: lockItems.length,
      itemBuilder: (context, index) {
        final lockItem = lockItems[index];
        return ListTile(
          leading: Icon(
            lockItem['status'] == "locked" || lockItem['status'] == "unlocking"
                ? Icons.lock
                : Icons.lock_open,
            color: Colors.green,
          ),
          title: Text('${lockItem['name']} status: ${lockItem['status']}'),
          trailing: SizedBox(
            width: 80,
            child: lockItem['status'] == 'locking' ||
                    lockItem['status'] == 'unlocking'
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Center(
                    child: TextButton(
                      onPressed: () {
                        handleButtonClick(lockItem);
                      },
                      child: Text(
                        lockItem['status'] == 'locked' ? 'Unlock' : 'Lock',
                        style: const TextStyle(
                          color: Colors.blue,
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
