import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/admin/providers/reports_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ReportsProvider.to;
    return Scaffold(
      appBar: AppBar(title: const Text(AdminStrings.reports)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ['all', 'job', 'user']
                  .map((t) => Obx(() => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(t),
                          selected: provider.typeFilter.value == t,
                          onSelected: (_) => provider.typeFilter.value = t,
                        ),
                      )))
                  .toList(),
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = provider.filteredReports;
              if (list.isEmpty) return const Center(child: Text('No reports'));
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final r = list[i];
                  return Dismissible(
                    key: Key(r.id),
                    background: Container(color: Colors.green, child: const Icon(Icons.check)),
                    secondaryBackground: Container(color: Colors.orange, child: const Icon(Icons.gavel)),
                    confirmDismiss: (dir) async {
                      if (dir == DismissDirection.startToEnd) {
                        await provider.dismissReport(r.id);
                        return true;
                      }
                      if (r.targetType == 'user') {
                        await provider.banFromReport(r.id, r.targetId);
                      } else {
                        await provider.removeJobFromReport(r.id, r.targetId);
                      }
                      return true;
                    },
                    child: ListTile(
                      title: Text(r.reportedByName),
                      subtitle: Text('${r.targetType}: ${r.reason}'),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
