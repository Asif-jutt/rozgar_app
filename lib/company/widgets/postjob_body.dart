import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class PostJobWidget extends StatefulWidget {
  final JobModel? jobToEdit;
  const PostJobWidget({super.key, this.jobToEdit});

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
    'Technology',
    'Design',
    'Marketing',
    'Remote',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _titleCtrl.text = job.title;
      _locationCtrl.text = job.location;
      _salaryCtrl.text = job.salary;
      _requirementsCtrl.text = job.requirements;
      _descCtrl.text = job.description;
      _imageUrlCtrl.text =
          job.imageUrl == AppImages.jobImageForCategory(job.category)
          ? ''
          : (job.imageUrl ?? '');
      if (_categories.contains(job.category)) {
        _category = job.category;
      }
    }
  }

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

  Future<void> _submitJob() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and description are required'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final userDoc = await _firestore.getUser(user.uid);
      final isUpdating = widget.jobToEdit != null;

      final imageUrl = _imageUrlCtrl.text.trim().isEmpty
          ? AppImages.jobImageForCategory(_category)
          : _imageUrlCtrl.text.trim();

      if (isUpdating) {
        // Update existing
        await _firestore.updateJob(widget.jobToEdit!.jobId, {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'salary': _salaryCtrl.text.trim().isEmpty
              ? 'Negotiable'
              : _salaryCtrl.text.trim(),
          'location': _locationCtrl.text.trim().isEmpty
              ? 'Remote'
              : _locationCtrl.text.trim(),
          'requirements': _requirementsCtrl.text.trim(),
          'category': _category,
          'imageUrl': imageUrl,
        });
      } else {
        // Create new
        final job = JobModel(
          jobId: '',
          companyId: user.uid,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          salary: _salaryCtrl.text.trim().isEmpty
              ? 'Negotiable'
              : _salaryCtrl.text.trim(),
          location: _locationCtrl.text.trim().isEmpty
              ? 'Remote'
              : _locationCtrl.text.trim(),
          requirements: _requirementsCtrl.text.trim(),
          category: _category,
          companyName: userDoc?.name ?? 'Company',
          imageUrl: imageUrl,
          postedAt: DateTime.now(),
        );
        await _firestore.createJob(job);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUpdating
                  ? 'Job updated successfully!'
                  : 'Job published successfully!',
            ),
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Go back whether from edit or post
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.jobToEdit != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isUpdating ? 'Edit Job Listing' : 'Post a New Job',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job Title *',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _salaryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Salary',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'General'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _requirementsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Requirements (comma separated)',
                  prefixIcon: Icon(Icons.list_alt),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job Image URL (optional)',
                  hintText: 'Leave empty for default image',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitJob,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(isUpdating ? Icons.save : Icons.publish),
                  label: Text(
                    isUpdating ? 'Save Changes' : 'Publish Job',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
