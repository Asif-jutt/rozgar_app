import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/connectivity_provider.dart';

class DevModeOverlay extends StatefulWidget {
  final Widget child;
  const DevModeOverlay({super.key, required this.child});

  @override
  State<DevModeOverlay> createState() => _DevModeOverlayState();
}

class _DevModeOverlayState extends State<DevModeOverlay> {
  double _frameMs = 0;
  bool _showPanel = false;
  Offset _position = const Offset(16, 100);

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration _) {
    if (!mounted) return;
    final now = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _frameMs = DateTime.now().difference(now).inMicroseconds / 1000;
      });
      WidgetsBinding.instance.addPostFrameCallback(_onFrame);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (d) => setState(() => _position += d.delta),
            onTap: () => setState(() => _showPanel = !_showPanel),
            child: _showPanel
                ? Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black87,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'DEV MODE',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Frame: ${_frameMs.toStringAsFixed(1)}ms',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'Firestore reads: ${FirestoreReadCounter.readCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'API: ${FirestoreReadCounter.lastApiDurationMs}ms',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          Obx(() => Text(
                                'Offline: ${ConnectivityProvider.to.isOffline.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              )),
                        ],
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.bug_report, size: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
