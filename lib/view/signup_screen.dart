// lib/views/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import 'widgets/custom_widgets.dart';

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
                Text(
                  "إنشاء حساب جديد",
                  style: AppTheme.headingLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  "انضم إلى مرشد - مساعد ذكي للجامعة",
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 32),

                // Full Name Field
                CustomTextField(
                  label: "الاسم الكامل",
                  hint: "أدخل اسمك الكامل",
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v!.isEmpty ? "الرجاء إدخال اسمك الكامل" : null,
                ),

                // University ID Field
                CustomTextField(
                  label: "رقم البطاقة الجامعية",
                  hint: "أدخل رقم بطاقتك",
                  controller: _uniIdController,
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? "الرجاء إدخال رقم البطاقة الجامعية" : null,
                ),

                // Email Field
                CustomTextField(
                  label: "البريد الإلكتروني",
                  hint: "example@murshid.com",
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      GetUtils.isEmail(v!) ? null : "الرجاء إدخال بريد صحيح",
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
                          "سيتم إرسال رابط تحقق إلى بريدك الإلكتروني",
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
                  label: "كلمة المرور",
                  hint: "•••••••••",
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) =>
                      v!.length < 6 ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل" : null,
                ),

                const SizedBox(height: 16),

                // Role Selection
                Text(
                  "اختر نوع الحساب:",
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: AppTheme.cardDecoration,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'student',
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "طالب",
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'professor',
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "محاضر",
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedRole = val!),
                  ),
                ),

                const SizedBox(height: 40),

                // Submit Button
                Obx(
                  () => CustomButton(
                    label: "إنشاء حساب",
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
                      "لديك حساب بالفعل؟ ",
                      style: AppTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        "تسجيل الدخول",
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
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
          "رقم بطاقة غير صحيح",
          "رقم البطاقة لا يطابق سجلات المحاضرين لدينا",
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
