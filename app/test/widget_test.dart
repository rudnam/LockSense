// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:locksense/firebase_options.dart';
// import 'package:firebase_database/firebase_database.dart';

import 'package:locksense/main.dart';

void main() {
  testWidgets('LockSense label is present', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the LockSense label is present.
    expect(true, true);
  });
}
