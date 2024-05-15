import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  late DatabaseReference _dbRef;
  late DatabaseReference ledStateRef;
  late DatabaseReference photoresistorStateRef;

  void initialize() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    _dbRef = FirebaseDatabase.instance.ref();
    ledStateRef = database.ref('led/state');
    photoresistorStateRef = database.ref('photoresistor/state');
  }

  Future<void> writeData(String path, dynamic newData) async {
    await _dbRef.child(path).set(newData);
  }

  void addLedStateListener(void Function(String) listener) {
    ledStateRef.onValue.listen((event) {
      final ledState = event.snapshot.value.toString();
      listener(ledState);
    });
  }

  void addPhotoresistorStateListener(void Function(String) listener) {
    photoresistorStateRef.onValue.listen((event) {
      final photoresistorState = event.snapshot.value.toString();
      listener(photoresistorState);
    });
  }
}
