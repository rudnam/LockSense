import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      await _firebaseMessaging.requestPermission();
      final fCMToken = await _firebaseMessaging.getToken();
      await _firebaseDatabase.ref().child("FCMToken").set(fCMToken);
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    } else {
      print("This platform doesn't support push notifications.");
    }
  }

  Future<void> writeData(String path, dynamic newData) async {
    await _firebaseDatabase.ref().child(path).set(newData);
  }

  Future<Object?> getData(String path) async {
    DataSnapshot snapshot = await _firebaseDatabase.ref().child(path).get();

    if (snapshot.exists) {
      return snapshot.value;
    } else {
      print('No data available.');
      return null;
    }
  }

  void addLockStateListener(String lockId, void Function(String) listener) {
    _firebaseDatabase.ref('locks/$lockId/state').onValue.listen((event) {
      final lockState = event.snapshot.value.toString();
      listener(lockState);
    });
  }

  void addNotificationListener(
      String userId, void Function(List<Map<String, dynamic>>?) listener) {
    _firebaseDatabase
        .ref('users/$userId/notifications')
        .onValue
        .listen((event) {
      final notifications = event.snapshot.value;
      List<Map<String, dynamic>> parsedNotifications = [];

      if (notifications != null && notifications is Map) {
        notifications.forEach((key, value) {
          if (value is Map) {
            parsedNotifications.add(Map<String, dynamic>.from(value));
          }
        });
      }

      listener(parsedNotifications);
    });
  }
}
