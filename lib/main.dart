import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rozgar/app.dart';
import 'package:rozgar/services/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exception}');
    }
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
    runApp(_BootstrapErrorApp(message: 'Firebase failed to start: $e'));
    return;
  }

  // FCM can hang or fail on web without a service worker — never block UI.
  if (!kIsWeb) {
    try {
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('NotificationService init skipped: $e');
    }
  }

  runApp(const Rozgar());
}

class _BootstrapErrorApp extends StatelessWidget {
  final String message;

  const _BootstrapErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
