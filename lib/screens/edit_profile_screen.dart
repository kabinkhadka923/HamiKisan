import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/localized_text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _farmingCategoryController;
  late TextEditingController _specializationController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _farmingCategoryController =
        TextEditingController(text: user?.farmingCategory ?? '');
    _specializationController =
        TextEditingController(text: user?.specialization ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _farmingCategoryController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('saving_profile'))),
    );

    await authProvider.updateProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      farmingCategory: user?.role == UserRole.farmer
          ? _farmingCategoryController.text.trim()
          : user?.farmingCategory,
      specialization: user?.role == UserRole.kisanDoctor
          ? _specializationController.text.trim()
          : user?.specialization,
    );

    // Hide loading and show success/error
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (authProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.tr('profile_updated_success')),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context
                  .tr('profile_update_failed')
                  .replaceAll('{error}', authProvider.error ?? '')),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('edit_profile'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.tr('full_name'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('enter_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: context.tr('address'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            if (user?.role == UserRole.farmer) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _farmingCategoryController,
                decoration: InputDecoration(
                  labelText: context.tr('farming_category_hint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.eco_outlined),
                ),
              ),
            ],
            if (user?.role == UserRole.kisanDoctor) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(
                  labelText: context.tr('specialization_hint'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.science_outlined),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(context.tr('save_changes'),
                      style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
