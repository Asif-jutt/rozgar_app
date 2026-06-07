import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rozgar/app.dart';
import 'package:rozgar/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
  });

  testWidgets('Rozgar app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const Rozgar());
    expect(find.byType(MaterialApp), findsOneWidget);
    // Flush splash screen delay timer
    await tester.pump(const Duration(seconds: 3));
  });
}
