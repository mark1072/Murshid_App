import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../models/user_model.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';
import '../services/student_management_service.dart';
import '../services/course_service.dart';
import 'schedule_controller.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  // متغيرات لمتابعة الحالة
  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  // دالة إنشاء حساب جديد
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String uniId,
    required String role,
  }) async {
    try {
      final connectivity = Get.find<ConnectivityService>();
      if (!connectivity.isConnected.value) {
        _showErrorSnackBar("يجب الاتصال بالإنترنت لإنشاء حساب جديد");
        return;
      }

      isLoading.value = true;
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        // نرسل البيانات هنا لتعويض الـ Trigger المحذوف
        data: {'full_name': name, 'university_id': uniId, 'role': role},
      );

      if (res.user != null) {
        // Create profile immediately after signup
        await supabase.from('profiles').insert({
          'id': res.user!.id,
          'full_name': name,
          'university_id': uniId,
          'role': role,
        });

        Get.snackbar("success".tr, "account_created_success".tr);
        // Navigate to course selection screen
        Get.offAllNamed(
          '/course_selection',
          arguments: {'userId': res.user!.id, 'role': role},
        );
      }
    } on AuthException catch (e) {
      // Handle rate limit error with user-friendly message
      if (e.message.toLowerCase().contains('rate limit') ||
          e.message.toLowerCase().contains('email rate')) {
        _showErrorSnackBar(
          "تم إرسال الكثير من الطلبات.\nحاول مرة أخرى بعد عدة دقائق.",
        );
      } else {
        _showErrorSnackBar(e.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // دالة تسجيل الدخول
  Future<void> login(String email, String password) async {
    final connectivity = Get.find<ConnectivityService>();
    final storage = Get.find<StorageService>();

    if (!connectivity.isConnected.value) {
      final cachedUser = storage.getCachedUser();
      if (cachedUser != null) {
        Get.snackbar(
          "تنبيه",
          "أنت غير متصل بالإنترنت، يمكنك تسجيل الدخول بالبيانات المحفوظة مسبقاً",
          backgroundColor: AppColors.primary.withOpacity(0.8),
          colorText: Colors.white,
        );
        currentUser.value = cachedUser;
        _navigateBasedOnRole(cachedUser.role);
        return;
      } else {
        _showErrorSnackBar("يجب الاتصال بالإنترنت لتسجيل الدخول لأول مرة");
        return;
      }
    }

    try {
      isLoading.value = true;

      // 1. محاولة تسجيل الدخول عبر Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 2. جلب بيانات البروفايل والدور (Role) من الجدول الذي أنشأناه
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', res.user!.id)
            .maybeSingle(); // Use maybeSingle instead of single to handle 0 rows

        if (data != null) {
          currentUser.value = UserModel.fromJson(data);
          // حفظ البيانات في Hive
          await storage.saveUser(currentUser.value!);

          // 3. التوجيه بناءً على الدور (Role)
          _navigateBasedOnRole(currentUser.value!.role);

          // 4. مزامنة البيانات في الخلفية
          performPostLoginSync();
        } else {
          // Profile doesn't exist, create it from auth metadata
          await _createProfileFromAuth(res.user!);
        }
      }
    } on AuthException catch (e) {
      // Handle rate limit error with user-friendly message
      if (e.message.toLowerCase().contains('rate limit') ||
          e.message.toLowerCase().contains('email rate')) {
        _showErrorSnackBar(
          "تم إرسال الكثير من الطلبات.\nحاول مرة أخرى بعد ساعه من الزمن.",
        );
      } else {
        // 4. عرض رسالة خطاء
        debugPrint('====\nAuth Error: $e');
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      debugPrint('====\nUnexpected Error: $e');
      _showErrorSnackBar("حدث خطأ غير متوقع، حاول مرة أخرى");
    } finally {
      isLoading.value = false;
    }
  }

  // مزامنة البيانات في الخلفية
  Future<void> performPostLoginSync() async {
    final connectivity = Get.find<ConnectivityService>();
    if (!connectivity.isConnected.value || currentUser.value == null) return;

    debugPrint("Starting background sync...");

    // Fetch Schedule
    try {
      if (Get.isRegistered<ScheduleController>()) {
        Get.find<ScheduleController>().fetchUserSchedule();
      }
    } catch (e) {
      debugPrint("Sync Error (Schedule): $e");
    }

    // Fetch Courses
    try {
      if (Get.isRegistered<CourseService>()) {
        Get.find<CourseService>().fetchAllCourses();
      }
    } catch (e) {
      debugPrint("Sync Error (Courses): $e");
    }

    // Fetch Students
    try {
      if (Get.isRegistered<StudentManagementService>()) {
        Get.find<StudentManagementService>().fetchAllStudents();
      }
    } catch (e) {
      debugPrint("Sync Error (Students): $e");
    }

    debugPrint("Background sync completed (failures ignored).");
  }

  // Create profile from auth user if it doesn't exist
  Future<void> _createProfileFromAuth(User user) async {
    try {
      final fullName = user.userMetadata?['full_name'] ?? 'User';
      final uniId = user.userMetadata?['university_id'] ?? '';
      final role = user.userMetadata?['role'] ?? 'student';

      // Insert profile record (without email - it's stored in auth table)
      await supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'university_id': uniId,
        'role': role,
      });

      currentUser.value = UserModel(
        id: user.id,
        fullName: fullName,
        universityId: uniId,
        role: role,
      );

      _navigateBasedOnRole(role);
    } catch (e) {
      debugPrint('Error creating profile: $e');
      _showErrorSnackBar("خطأ في إنشاء الملف الشخصي");
    }
  }

  // دالة التوجيه (Navigation Logic)
  void _navigateBasedOnRole(String role) {
    if (role == 'student') {
      Get.offAllNamed('/student_home');
    } else if (role == 'professor') {
      Get.offAllNamed('/professor_home');
    }
  }

  // عرض رسائل الخطأ بشكل أنيق
  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "خطأ",
      message,
      snackPosition: SnackPosition.BOTTOM,
      // ignore: deprecated_member_use
      backgroundColor: AppColors.error.withOpacity(0.8),
      colorText: AppColors.secondary,
      margin: EdgeInsets.all(AppSizes.p16),
    );
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }
}
