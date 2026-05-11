import 'package:flutter/material.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/user/models/job_model.dart';

class PostJobWidget extends StatefulWidget {
  const PostJobWidget({super.key});

  @override
  State<PostJobWidget> createState() => _PostJobWidgetState();
}

class _PostJobWidgetState extends State<PostJobWidget> {
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  String selectedJobType = "Full-time";
  bool isLoading = false;

  @override
  void dispose() {
    jobTitleController.dispose();
    companyNameController.dispose();
    locationController.dispose();
    salaryController.dispose();
    descriptionController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    // Validation
    if (jobTitleController.text.trim().isEmpty) {
      _showError('Please enter job title');
      return;
    }
    if (companyNameController.text.trim().isEmpty) {
      _showError('Please enter company name');
      return;
    }
    if (locationController.text.trim().isEmpty) {
      _showError('Please enter location');
      return;
    }
    if (salaryController.text.trim().isEmpty) {
      _showError('Please enter salary');
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showError('Please enter job description');
      return;
    }
    if (skillsController.text.trim().isEmpty) {
      _showError('Please enter required skills');
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showError('Please log in first');
      return;
    }

    setState(() => isLoading = true);

    try {
      final skills = skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final job = Job(
        id: '', // Firestore will generate ID
        jobTitle: jobTitleController.text.trim(),
        companyName: companyNameController.text.trim(),
        companyId: currentUser.uid,
        location: locationController.text.trim(),
        salary: salaryController.text.trim(),
        requiredSkills: skills,
        description: descriptionController.text.trim(),
        postedDate: DateTime.now(),
        jobType: selectedJobType,
        image: 'assets/Images/default_job.png',
      );

      await _databaseService.createJob(job);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully!')),
      );

      // Clear form
      jobTitleController.clear();
      companyNameController.clear();
      locationController.clear();
      salaryController.clear();
      descriptionController.clear();
      skillsController.clear();
      setState(() => selectedJobType = 'Full-time');
    } catch (e) {
      _showError('Error posting job: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Job Title
          TextField(
            controller: jobTitleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Job Title",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.work, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Company Name
          TextField(
            controller: companyNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Company Name",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.business, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Location
          TextField(
            controller: locationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Location",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Salary
          TextField(
            controller: salaryController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Salary (e.g., 80k - 120k)",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Job Description
          TextField(
            controller: descriptionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Job Description",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.description, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Required Skills
          TextField(
            controller: skillsController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Required Skills (comma-separated)",
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: "e.g., Flutter, Dart, Firebase",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.code, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Job Type Dropdown
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1E1E1E),
            value: selectedJobType,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: "Full-time", child: Text("Full-time")),
              DropdownMenuItem(value: "Part-time", child: Text("Part-time")),
              DropdownMenuItem(value: "Contract", child: Text("Contract")),
            ],
            onChanged: (newValue) {
              setState(() => selectedJobType = newValue!);
            },
            decoration: InputDecoration(
              labelText: "Job Type",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Post Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading ? null : _postJob,
              child: isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Text(
                "Post Job",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}