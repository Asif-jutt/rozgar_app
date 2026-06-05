import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/providers/applicants_provider.dart';
import 'package:rozgar/company/widgets/applicant_card.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    final jobId = Get.arguments as String;
    ApplicantsProvider.to.loadApplicants(jobId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ApplicantsProvider.to;
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['all', 'pending', 'viewed', 'accepted', 'rejected']
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(s),
                              selected: provider.statusFilter.value == s,
                              onSelected: (_) => provider.statusFilter.value = s,
                            ),
                          ))
                      .toList(),
                )),
          ),
          Expanded(
            child: Obx(() {
              final list = provider.filteredApplicants;
              if (list.isEmpty) return const Center(child: Text('No applicants'));
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => ApplicantCard(applicant: list[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
