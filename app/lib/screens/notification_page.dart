// notification_page.dart
import 'package:flutter/material.dart';
import '../widgets/notification_list.dart';
import '../services/firebase_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FirebaseService firebaseService;
  List<Map<String, dynamic>>? notifications;
  bool isLoading = true;
  String userId = "demo-user";

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    Object? data = await firebaseService.getData('users/$userId/notifications');
    if (data != null && data is Map) {
      List<Map<String, dynamic>> parsedNotifications = [];
      data.forEach((key, value) {
        if (value is Map) {
          parsedNotifications.add(Map<String, dynamic>.from(value));
        }
      });
      setState(() {
        notifications = parsedNotifications;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
              isLoading
                  ? CircularProgressIndicator()
                  : notifications != null
                      ? Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child:
                                NotificationList(notifications: notifications!),
                          ),
                        )
                      : Text('No notifications available'),
            ],
          ),
        );
      },
    );
  }
}
