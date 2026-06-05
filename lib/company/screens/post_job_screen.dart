import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/providers/post_job_provider.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/widgets/ad_banner_widget.dart';
import 'package:rozgar/user/widgets/custom_button.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _salaryMin = TextEditingController();
  final _salaryMax = TextEditingController();
  final _req = TextEditingController();
  String _country = 'Pakistan';
  String _currency = 'PKR';
  String _type = 'fullTime';
  Timestamp? _deadline;
  final _provider = PostJobProvider.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Job Title *', filled: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description *', filled: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _req,
                      decoration: const InputDecoration(labelText: 'Requirement', filled: true),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _provider.addRequirement(_req.text);
                      _req.clear();
                    },
                  ),
                ],
              ),
              Obx(() => Wrap(
                    spacing: 8,
                    children: _provider.requirements
                        .asMap()
                        .entries
                        .map((e) => Chip(
                              label: Text(e.value),
                              onDeleted: () => _provider.removeRequirement(e.key),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'City *', filled: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              Obx(() => DropdownButtonFormField<String>(
                    value: _country,
                    decoration: const InputDecoration(labelText: 'Country', filled: true),
                    items: _provider.countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _country = v ?? 'Pakistan'),
                  )),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMin,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Min $_currency', filled: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMax,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Max $_currency', filled: true),
                    ),
                  ),
                ],
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'PKR', label: Text('PKR')),
                  ButtonSegment(value: 'USD', label: Text('USD')),
                ],
                selected: {_currency},
                onSelectionChanged: (s) => setState(() => _currency = s.first),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fullTime', label: Text('Full-time')),
                  ButtonSegment(value: 'partTime', label: Text('Part-time')),
                  ButtonSegment(value: 'remote', label: Text('Remote')),
                  ButtonSegment(value: 'contract', label: Text('Contract')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              ListTile(
                title: Text(_deadline == null
                    ? 'Set deadline'
                    : 'Deadline: ${_deadline!.toDate()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (d != null) setState(() => _deadline = Timestamp.fromDate(d));
                },
              ),
              const SizedBox(height: 16),
              Obx(() => CustomButton(
                    label: 'Post Job',
                    isLoading: _provider.isPosting.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _provider.postJob({
                          'title': _title.text,
                          'companyName':
                              AuthProvider.to.currentUser.value?.displayName,
                          'location': _location.text,
                          'country': _country,
                          'salaryMin': double.tryParse(_salaryMin.text) ?? 0,
                          'salaryMax': double.tryParse(_salaryMax.text) ?? 0,
                          'currency': _currency,
                          'description': _desc.text,
                          'type': _type,
                          'deadline': _deadline,
                        });
                      }
                    },
                  )),
              const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
