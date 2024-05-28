import 'package:flutter/material.dart';
import '../widgets/notification_list.dart';

class NotificationPage extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback clearNotifications;

  const NotificationPage({
    super.key,
    required this.notifications,
    required this.clearNotifications,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: widget.clearNotifications,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              widget.notifications.isNotEmpty
                  ? Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: NotificationList(
                            notifications: widget.notifications),
                      ),
                    )
                  : const Text('No notifications available'),
            ],
          ),
        );
      },
    );
  }
}
