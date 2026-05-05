import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedGrade;
  String? _selectedBoard;
  String? _selectedMedium;

  final List<String> _grades = ['9', '10', '11', '12', 'MDCAT', 'ECAT'];
  final List<String> _boards = ['Punjab', 'Sindh', 'KPK', 'Federal', 'AKU'];
  final List<String> _mediums = ['English', 'Urdu'];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _selectedGrade = user?.grade;
    _selectedBoard = user?.board;
    _selectedMedium = user?.medium ?? 'English';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (pickedFile != null && mounted) {
      final success = await context.read<UserProvider>().updateAvatar(pickedFile.path);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.lightTeal,
                          backgroundImage: user?.avatarUrl != null 
                            ? NetworkImage(user!.avatarUrl!) 
                            : null,
                          child: user?.avatarUrl == null 
                            ? const Icon(Icons.person, size: 60, color: AppColors.primaryTeal) 
                            : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: provider.isLoading ? null : _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        if (provider.isLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primaryTeal),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryTeal),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Email (Disabled)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryTeal),
                    ),
                    enabled: false,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Academic Preferences',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Grade Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      labelText: 'Grade / Target Exam',
                      prefixIcon: Icon(Icons.school_outlined, color: AppColors.primaryTeal),
                    ),
                    items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _selectedGrade = val),
                    validator: (value) => value == null ? 'Please select your grade' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  // Board Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBoard,
                    decoration: const InputDecoration(
                      labelText: 'Education Board',
                      prefixIcon: Icon(Icons.map_outlined, color: AppColors.primaryTeal),
                    ),
                    items: _boards.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                    onChanged: (val) => setState(() => _selectedBoard = val),
                    validator: (value) => value == null ? 'Please select your board' : null,
                  ),
                  const SizedBox(height: 20),

                  // Medium Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMedium,
                    decoration: const InputDecoration(
                      labelText: 'Study Medium',
                      prefixIcon: Icon(Icons.language_outlined, color: AppColors.primaryTeal),
                    ),
                    items: _mediums.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) => setState(() => _selectedMedium = val),
                    validator: (value) => value == null ? 'Please select your medium' : null,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: provider.isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<UserProvider>().updateUser({
        'name': _nameController.text.trim(),
        'grade': _selectedGrade,
        'board': _selectedBoard,
        'medium': _selectedMedium,
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile.')),
          );
        }
      }
    }
  }
}
