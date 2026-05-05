import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedGrade;
  String? _selectedBoard;

  final List<String> _grades = ['9', '10', '11', '12', 'MDCAT', 'ECAT'];
  final List<String> _boards = ['Punjab', 'Sindh', 'KPK', 'Federal', 'AKU'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Join thousands of students preparing with AI',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 32),
                    
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name is required';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 20),
                    
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!value.contains('@')) return 'Invalid email address';
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 20),
                    
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms),
                    
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
                    ).animate().fadeIn(delay: 600.ms),
                    
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
                    ).animate().fadeIn(delay: 700.ms),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await provider.register({
                              'name': _nameController.text.trim(),
                              'email': _emailController.text.trim(),
                              'password': _passwordController.text,
                              'grade': _selectedGrade,
                              'board': _selectedBoard,
                            });
                            
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration successful! Please login.')),
                              );
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration failed. Email might already be taken.')),
                              );
                            }
                          }
                        },
                        child: provider.isLoading 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Register'),
                      ).animate().fadeIn(delay: 800.ms).scale(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
