import 'package:flutter/material.dart';
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

  final List<String> _grades = ['9', '10', '11', '12', 'MDCAT', 'ECAT'];
  final List<String> _boards = ['Punjab', 'Sindh', 'KPK', 'Federal', 'AKU'];

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _selectedGrade = user?.grade;
    _selectedBoard = user?.board;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update your information',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
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
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryTeal),
                    ),
                    enabled: false,
                    style: TextStyle(color: Colors.grey[600]),
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
                  
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isLoading ? Colors.grey[300] : AppColors.primaryTeal,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: provider.isLoading 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Save Changes'),
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
        'name': _nameController.text,
        'grade': _selectedGrade,
        'board': _selectedBoard,
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile. Please check the debug console for details.')),
          );
        }
      }
    }
  }
}
