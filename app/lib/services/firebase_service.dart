import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseService {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  late DatabaseReference ledStateRef;
  late DatabaseReference photoresistorStateRef;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    await _firebaseDatabase.ref().child("FCMToken").set(fCMToken);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> writeData(String path, dynamic newData) async {
    await _firebaseDatabase.ref().child(path).set(newData);
  }

  void addLedStateListener(void Function(String) listener) {
    _firebaseDatabase.ref('led/state').onValue.listen((event) {
      final ledState = event.snapshot.value.toString();
      listener(ledState);
    });
  }

  void addPhotoresistorStateListener(void Function(String) listener) {
    _firebaseDatabase.ref('photoresistor/state').onValue.listen((event) {
      final photoresistorState = event.snapshot.value.toString();
      listener(photoresistorState);
    });
  }
}
