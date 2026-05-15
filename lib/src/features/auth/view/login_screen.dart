// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_theme.dart';
import 'package:musrshid_app/src/core/constants/app_sizes.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/core/widgets/language_toggle.dart';
import 'package:musrshid_app/src/core/widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 60,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 60,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'welcome_to_murshid'.tr,
                        style: AppTheme.headingLarge.copyWith(
                          color: AppColors.accent,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'smart_university_assistant'.tr,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('login_title'.tr, style: AppTheme.headingMedium),
                      const SizedBox(height: 8),
                      Text(
                        'enter_credentials'.tr,
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(height: 28),

                      // Email Field
                      CustomTextField(
                        label: 'email'.tr,
                        hint: 'email_hint'.tr,
                        controller: emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_email'.tr;
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'please_enter_valid_email'.tr;
                          }
                          return null;
                        },
                      ),

                      // Password Field
                      CustomTextField(
                        label: 'password'.tr,
                        hint: 'password_hint'.tr,
                        controller: passwordController,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_password'.tr;
                          }
                          if (value.length < 6) {
                            return 'password_min_length'.tr;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      Obx(
                        () => CustomButton(
                          label: 'login'.tr,
                          isLoading: authController.isLoading.value,
                          onPressed: () {
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              authController.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            } else {
                              Get.snackbar(
                                'error'.tr,
                                'please_fill_all_fields'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Signup Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('no_account'.tr, style: AppTheme.bodySmall),
                          GestureDetector(
                            onTap: () => Get.toNamed('/signup'),
                            child: Text(
                              'register_now'.tr,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
