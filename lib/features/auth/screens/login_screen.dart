import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../../dashboard/screens/dashboard_shell.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn().slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Login to continue your preparation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 40),
                    
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
                    
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        return null;
                      },
                    ).animate().fadeIn(delay: 600.ms),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColors.primaryTeal),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await provider.login(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            
                            if (success && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const DashboardShell()),
                                (route) => false,
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed. Please check your credentials.')),
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
                          : const Text('Login'),
                      ).animate().fadeIn(delay: 1000.ms).scale(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1200.ms),
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
