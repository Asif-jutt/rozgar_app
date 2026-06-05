import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _maintenance = false;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = info.version);
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.config)
        .doc('app')
        .get();
    if (doc.exists) {
      setState(() =>
          _maintenance = doc.data()?['maintenanceMode'] as bool? ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AdminStrings.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Maintenance Mode'),
            value: _maintenance,
            onChanged: (v) async {
              setState(() => _maintenance = v);
              await FirebaseFirestore.instance
                  .collection(FirebaseCollections.config)
                  .doc('app')
                  .set({'maintenanceMode': v}, SetOptions(merge: true));
            },
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: Text(_version),
          ),
          ListTile(
            title: const Text('Export User Data'),
            trailing: const Icon(Icons.download),
            onTap: () async {
              final snap = await FirebaseFirestore.instance
                  .collection(FirebaseCollections.users)
                  .get();
              final csv = StringBuffer('uid,email,role\n');
              for (final d in snap.docs) {
                final data = d.data();
                csv.writeln('${d.id},${data['email']},${data['role']}');
              }
              Get.snackbar('Export', 'CSV ready (${snap.docs.length} users)');
            },
          ),
          ListTile(
            title: const Text('View Crash Logs'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => launchUrl(
              Uri.parse('https://console.firebase.google.com'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
    );
  }
}
