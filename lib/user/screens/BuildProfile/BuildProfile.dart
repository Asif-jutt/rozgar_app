import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/user/models/user_model.dart';

class BuildprofileUI extends StatefulWidget {
  const BuildprofileUI({super.key});

  @override
  State<BuildprofileUI> createState() => _BuildprofileUIState();
}

class _BuildprofileUIState extends State<BuildprofileUI> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final List<String> availableSkills = [
    'Flutter',
    'React Native',
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'SQL',
    'MongoDB',
    'Firebase',
    'AWS',
    'Docker',
    'UI Design',
    'UX Design',
    'Dart',
    'Node.js',
  ];

  final List<String> degrees = ['Matric', 'Bachelor', 'Master', 'PhD'];

  List<String> selectedSkills = [];
  String? selectedDegree;
  String? selectedInstitution;
  bool isLoading = false;

  final TextEditingController institutionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    cnicController.dispose();
    addressController.dispose();
    institutionController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.add(skill);
      }
    });
  }

  Future<void> _saveProfile() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final education = selectedDegree != null
          ? Education(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        degree: selectedDegree!,
        institution: institutionController.text.trim(),
        year: yearController.text.trim().isNotEmpty
            ? yearController.text.trim()
            : null,
      )
          : null;

      List<Education> educations = [];
      if (education != null) {
        educations.add(education);
      }

      await _databaseService.updateUserFields(
        currentUser.uid,
        {
          'phoneNumber': phoneController.text.trim(),
          'cnic': cnicController.text.trim(),
          'address': addressController.text.trim(),
          'skills': selectedSkills,
          'educations': educations.map((e) => e.toJson()).toList(),
          'profileComplete': true,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.buildProfile,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Number
            CustomTextField(
              controller: phoneController,
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // CNIC
            CustomTextField(
              controller: cnicController,
              label: 'CNIC',
              hintText: 'Enter your CNIC number',
              prefixIcon: Icons.card_membership,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Address
            CustomTextField(
              controller: addressController,
              label: AppStrings.address,
              hintText: 'Enter your address',
              prefixIcon: Icons.location_on,
              maxLines: 2,
              minLines: 2,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Skills Section
            Text(AppStrings.selectSkills, style: AppTextStyles.headline4),
            const SizedBox(height: 8),
            Text('Select skills from the list', style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableSkills
                  .map((skill) => FilterChip(
                label: Text(skill),
                selected: selectedSkills.contains(skill),
                onSelected: (_) => _toggleSkill(skill),
              ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Education Section
            Text(AppStrings.enterDegrees, style: AppTextStyles.headline4),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Degree'),
              value: selectedDegree,
              items: degrees
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedDegree = value);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: institutionController,
              label: 'Institution',
              hintText: 'Enter your institution name',
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: yearController,
              label: 'Graduation Year',
              hintText: 'e.g., 2023',
              prefixIcon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Save Button
            CustomButton(
              text: 'Save Profile',
              isLoading: isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
