import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationList({required this.notifications, super.key});

  @override
  Widget build(BuildContext context) {
    notifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        IconData iconData;
        switch (notification['type']) {
          case 'unlocked':
            iconData = Icons.lock_open;
            break;
          case 'locked':
            iconData = Icons.lock;
            break;
          case 'failure':
            iconData = Icons.access_alarm;
            break;
          default:
            iconData = Icons.info;
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: ListTile(
            leading: Icon(iconData),
            title: Text(notification['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['body']),
                const SizedBox(height: 5),
                Text(
                  'Time: ${DateFormat.yMd().add_jms().format(DateTime.fromMillisecondsSinceEpoch(notification['timestamp']))}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
