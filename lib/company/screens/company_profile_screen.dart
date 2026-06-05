import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/providers/company_profile_provider.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _name = TextEditingController();
  final _website = TextEditingController();
  final _industry = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = CompanyProfileProvider.to.company.value;
    if (c != null) {
      _name.text = c.name;
      _website.text = c.website ?? '';
      _industry.text = c.industry ?? '';
      _desc.text = c.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = CompanyProfileProvider.to;
    return Scaffold(
      appBar: AppBar(title: const Text('Company Profile')),
      body: Obx(() {
        final c = provider.company.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: provider.uploadLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      c?.logoUrl != null ? CachedNetworkImageProvider(c!.logoUrl!) : null,
                  child: c?.logoUrl == null ? const Icon(Icons.business, size: 40) : null,
                ),
              ),
              if (provider.isUploading.value)
                LinearProgressIndicator(value: provider.uploadProgress.value),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Company Name', filled: true),
              ),
              TextField(
                controller: _website,
                decoration: const InputDecoration(labelText: 'Website', filled: true),
              ),
              TextField(
                controller: _industry,
                decoration: const InputDecoration(labelText: 'Industry', filled: true),
              ),
              TextField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', filled: true),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => provider.updateCompanyProfile({
                  'name': _name.text,
                  'website': _website.text,
                  'industry': _industry.text,
                  'description': _desc.text,
                }),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
