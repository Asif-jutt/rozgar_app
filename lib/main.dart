import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rozgar/app.dart';
import 'package:rozgar/core/app_initializer.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized');
  } catch (e, st) {
    AppLogger.error('Firebase init failed', e, st);
    runApp(_BootstrapErrorApp(message: 'Firebase failed to start: $e'));
    return;
  }

  await AppInitializer.instance.initialize();

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
