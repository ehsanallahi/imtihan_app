import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightTeal,
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo Placeholder
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                  
                  const SizedBox(height: 40),
                  Text(
                    'Imtihan',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.darkTeal,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 16),
                  Text(
                    "Pakistan's AI-Powered Exam Preparation",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Login'),
                      ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1),
                      
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: AppColors.primaryTeal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.1),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer Text
                  Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ).animate().fadeIn(delay: 1200.ms),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Optional Crimson Curve/Accent
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
