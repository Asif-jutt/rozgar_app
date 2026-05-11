import 'package:flutter/material.dart';
import '../widgets/drawer_company.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/models/application_model.dart';

class ManageApplicantsPage extends StatefulWidget {
  const ManageApplicantsPage({super.key});

  @override
  State<ManageApplicantsPage> createState() => _ManageApplicantsPageState();
}

class _ManageApplicantsPageState extends State<ManageApplicantsPage> {
  final _db = DatabaseService();
  final _auth = AuthService();

  Future<List<Job>> _loadJobs() async {
    final companyId = _auth.currentUserId;
    if (companyId == null) return [];
    return await _db.getCompanyJobs(companyId);
  }

  Future<void> _acceptApplicant(JobApplication app) async {
    await _db.updateApplicationStatus(app.id, 'accepted');
    await _db.updateUserFields(app.userId, {
      'lastApplicationStatus': 'accepted',
      'lastApplicationJobId': app.jobId,
    });
  }

  Future<void> _rejectApplicant(JobApplication app) async {
    await _db.updateApplicationStatus(app.id, 'rejected');
    await _db.updateUserFields(app.userId, {
      'lastApplicationStatus': 'rejected',
      'lastApplicationJobId': app.jobId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Manage Applicants"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Job>>(
        future: _loadJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(child: Text('No jobs found', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(job.jobTitle, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(job.companyName, style: const TextStyle(color: Colors.white70)),
                  children: [
                    FutureBuilder<List<JobApplication>>(
                      future: _db.getJobApplications(job.id),
                      builder: (context, appsSnap) {
                        if (appsSnap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (appsSnap.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${appsSnap.error}'),
                          );
                        }

                        final apps = appsSnap.data ?? [];
                        if (apps.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No applicants yet', style: TextStyle(color: Colors.white70)),
                          );
                        }

                        return Column(
                          children: apps.map((app) {
                            return ListTile(
                              title: Text(app.userName ?? app.userId, style: const TextStyle(color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${app.status}', style: const TextStyle(color: Colors.white70)),
                                  Text('Applied: ${app.appliedDate.day}/${app.appliedDate.month}/${app.appliedDate.year}', style: const TextStyle(color: Colors.white54)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () async {
                                      await _acceptApplicant(app);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applicant accepted')));
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () async {
                                      await _rejectApplicant(app);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applicant rejected')));
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      drawer: const CompanyDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: "Post Job",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: "Help",
          ),
        ],
      ),
    );
  }
}