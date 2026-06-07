import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/firebase_options.dart';

const backgroundTaskName = 'rozgarSyncTask';

@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.info('Background task started: $task');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (task == backgroundTaskName) {
        await _syncPendingNotifications();
      }
      return true;
    } catch (e, st) {
      AppLogger.error('Background task failed', e, st);
      return false;
    }
  });
}

Future<void> _syncPendingNotifications() async {
  final snap = await FirebaseFirestore.instance
      .collection('notifications')
      .where('read', isEqualTo: false)
      .limit(20)
      .get();
  AppLogger.info('Background sync: ${snap.docs.length} unread notifications');
}

/// Registers periodic background sync using Workmanager.
class BackgroundTaskService {
  BackgroundTaskService._();
  static final BackgroundTaskService instance = BackgroundTaskService._();

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await Workmanager().initialize(backgroundTaskDispatcher);
      await Workmanager().registerPeriodicTask(
        'rozgar-periodic-sync',
        backgroundTaskName,
        frequency: const Duration(hours: 6),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      AppLogger.info('BackgroundTaskService registered');
    } catch (e, st) {
      AppLogger.error('BackgroundTaskService init failed', e, st);
    }
  }
}
