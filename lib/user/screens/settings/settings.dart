import 'package:flutter/material.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _emailCtl;
  final TextEditingController _passwordCtl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameCtl = TextEditingController(text: user?.displayName ?? '');
    _emailCtl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = _auth.currentUser;
    try {
      if (user != null) {
        // Update display name in Firestore and user document
        await _db.updateUserFields(user.uid, {'fullName': _nameCtl.text.trim()});

        // Update email in user profile document only (auth email update may require re-auth)
        if (_emailCtl.text.trim() != (user.email ?? '')) {
          await _db.updateUserFields(user.uid, {'email': _emailCtl.text.trim()});
          // Inform user that changing authentication email requires re-authentication
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email updated in profile. To change authentication email, re-login or use account recovery.'),
            duration: Duration(seconds: 4),
          ));
        }

        // If user provided a new password, send password reset link to their email
        if (_passwordCtl.text.isNotEmpty) {
          if (_passwordCtl.text.length < 6) throw Exception('Password must be at least 6 characters');
          final emailToSend = _emailCtl.text.trim().isNotEmpty ? _emailCtl.text.trim() : (user.email ?? '');
          if (emailToSend.isNotEmpty) {
            await _auth.resetPassword(emailToSend);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
          } else {
            throw Exception('No email available to send password reset');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings updated')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtl,
                decoration: const InputDecoration(labelText: 'New password (leave blank to keep)'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const CircularProgressIndicator() : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
