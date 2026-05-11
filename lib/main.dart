import 'package:flutter/material.dart';
import 'package:rozgar/app.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

String _emulatorHost() {
  if (kIsWeb) {
    return 'localhost';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return '10.0.2.2';
  }

  return 'localhost';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      final host = _emulatorHost();
      if (kIsWeb) {
        // For web, explicitly set localhost and handle any connection issues
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        if (kDebugMode) {
          print('✓ Configured to use Auth Emulator on localhost:9099');
          print('✓ Configured to use Firestore Emulator on localhost:8080');
        }
      } else {
        FirebaseAuth.instance.useAuthEmulator(host, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
        if (kDebugMode) {
          print('✓ Configured to use emulators on $host');
        }
      }
    } catch (e) {
      print('⚠ Error configuring emulators: $e');
    }
  }

  runApp(const Rozgar());
}