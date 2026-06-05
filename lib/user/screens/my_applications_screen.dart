import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/application_provider.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: MyApplicationsScreen');
    final apps = ApplicationProvider.to;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Applications'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Viewed'),
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              _list(apps.myApplications),
              _list(apps.myApplications.where((a) => a.status == 'pending')),
              _list(apps.myApplications.where((a) => a.status == 'viewed')),
              _list(apps.myApplications.where((a) => a.status == 'accepted')),
              _list(apps.myApplications.where((a) => a.status == 'rejected')),
            ],
          );
        }),
      ),
    );
  }

  Widget _list(Iterable apps) {
    final list = apps.toList();
    if (list.isEmpty) {
      return const Center(child: Text(AppStrings.noApplications));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final app = list[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(app.jobTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(app.companyName),
            trailing: Chip(
              label: Text(app.statusLabel, style: TextStyle(color: app.statusColor)),
              backgroundColor: app.statusColor.withValues(alpha: 0.1),
            ),
          ),
        );
      },
    );
  }
}
