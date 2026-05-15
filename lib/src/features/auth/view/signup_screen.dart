// lib/views/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_theme.dart';
import 'package:musrshid_app/src/core/widgets/language_toggle.dart';
import 'package:musrshid_app/src/core/widgets/role_toggle.dart';
import 'package:musrshid_app/src/core/widgets/custom_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uniIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'student';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _uniIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Toggle at the top, centered
                Center(
                  child: RoleToggle(
                    selectedRole: _selectedRole,
                    onChanged: (val) => setState(() => _selectedRole = val),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'create_new_account'.tr,
                  style: AppTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'join_murshid'.tr,
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 32),

                // Full Name Field
                CustomTextField(
                  label: 'full_name'.tr,
                  hint: 'enter_full_name'.tr,
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v!.isEmpty ? 'please_enter_full_name'.tr : null,
                ),

                // University ID Field
                CustomTextField(
                  label: 'university_id'.tr,
                  hint: 'enter_university_id'.tr,
                  controller: _uniIdController,
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? 'please_enter_university_id'.tr : null,
                ),

                // Email Field
                CustomTextField(
                  label: 'email'.tr,
                  hint: 'email_hint'.tr,
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      GetUtils.isEmail(v!) ? null : 'please_enter_valid_email_short'.tr,
                ),

                // Email Verification Hint
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'email_verification_hint'.tr,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Password Field
                CustomTextField(
                  label: 'password'.tr,
                  hint: '•••••••••',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) =>
                      v!.length < 6 ? 'password_min_length'.tr : null,
                ),

                const SizedBox(height: 24),

                // Submit Button
                Obx(
                  () => CustomButton(
                    label: 'create_account'.tr,
                    isLoading: authController.isLoading.value,
                    onPressed: _handleSignup,
                  ),
                ),

                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already_have_account'.tr,
                      style: AppTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'login'.tr,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Center(child: LanguageToggle()),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // Validate university ID for professors
      if (_selectedRole == 'professor' &&
          !_uniIdController.text.trim().startsWith('200')) {
        Get.snackbar(
          'invalid_id'.tr,
          'id_not_matching'.tr,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        uniId: _uniIdController.text.trim(),
        role: _selectedRole,
      );
    }
  }
}
