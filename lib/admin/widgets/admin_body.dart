import 'package:flutter/material.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/user/models/job_model.dart';

class AdminBody extends StatelessWidget {
  const AdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "View All Jobs Status",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<List<Job>>(
            stream: db.getAllJobsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final jobs = snapshot.data ?? [];

              // Only show jobs that were created by companies (have a non-empty companyId)
              final realJobs = jobs.where((j) => j.companyId != null && j.companyId!.isNotEmpty).toList();

              if (realJobs.isEmpty) {
                return const Center(
                  child: Text('No jobs found', style: TextStyle(color: Colors.white)),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: realJobs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final job = realJobs[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.work, color: Colors.blue, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                job.jobTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.companyName,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              job.postedDate.day.toString() + '/' + job.postedDate.month.toString(),
                              style: const TextStyle(color: Colors.white54),
                            ),
                            ElevatedButton(
                              onPressed: () => _showApplicantsDialog(context, db, job),
                              child: const Text('View Applicants'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showApplicantsDialog(BuildContext context, DatabaseService db, Job job) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF121212),
        child: SizedBox(
          width: 600,
          height: 400,
          child: FutureBuilder<List>(
            future: db.getJobApplications(job.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final apps = snapshot.data ?? [];
              if (apps.isEmpty) {
                return Center(child: Text('No applicants for ${job.jobTitle}', style: const TextStyle(color: Colors.white)));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: apps.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    title: Text(app.userName ?? app.userId ?? 'Applicant', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Status: ${app.status}', style: const TextStyle(color: Colors.white70)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await db.updateApplicationStatus(app.id, 'accepted');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applicant accepted')));
                            Navigator.of(context).pop();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await db.updateApplicationStatus(app.id, 'rejected');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applicant rejected')));
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}