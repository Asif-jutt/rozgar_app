import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class PostJobWidget extends StatefulWidget {
  const PostJobWidget({super.key});

  @override
  State<PostJobWidget> createState() => _PostJobWidgetState();
}

class _PostJobWidgetState extends State<PostJobWidget> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _requirementsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String _category = 'Technology';
  bool _loading = false;
  final _firestore = FirestoreService();

  static const _categories = [
    'Technology', 'Design', 'Marketing', 'Remote', 'General',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _requirementsCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final userDoc = await _firestore.getUser(user.uid);
      final job = JobModel(
        jobId: '',
        companyId: user.uid,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        salary: _salaryCtrl.text.trim().isEmpty ? 'Negotiable' : _salaryCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? 'Remote' : _locationCtrl.text.trim(),
        requirements: _requirementsCtrl.text.trim(),
        category: _category,
        companyName: userDoc?.name ?? 'Company',
        imageUrl: _imageUrlCtrl.text.trim().isEmpty
            ? AppImages.jobImageForCategory(_category)
            : _imageUrlCtrl.text.trim(),
        postedAt: DateTime.now(),
      );
      await _firestore.createJob(job);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job published!'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.pushReplacementNamed(context, '/company_dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Post a New Job', style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Job Title *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationCtrl,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _salaryCtrl,
            decoration: const InputDecoration(labelText: 'Salary'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'General'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _requirementsCtrl,
            decoration: const InputDecoration(
              labelText: 'Requirements (comma separated)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _imageUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'Job Image URL (optional)',
              hintText: 'Leave empty for default image',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: _loading ? null : _postJob,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publish Job'),
            ),
          ),
        ],
      ),
    );
  }
}
