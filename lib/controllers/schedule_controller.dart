import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';
import 'auth_controller.dart';

class ScheduleController extends GetxController {
  final supabase = Supabase.instance.client;

  // نصل لـ AuthController لجلب بيانات المستخدم الحالي
  final AuthController _authController = Get.find<AuthController>();

  // متغيرات الحالة
  var isLoading = false.obs;
  var schedules = <ScheduleModel>[].obs; // قائمة الجدول الدراسي الكاملة
  var upcomingLecture = Rxn<ScheduleModel>(); // المحاضرة القادمة فقط

  @override
  void onInit() {
    super.onInit();
    // جلب البيانات بمجرد تشغيل الـ Controller
    fetchUserSchedule();
  }

  Future<void> fetchUserSchedule() async {
    try {
      isLoading.value = true;

      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      // جلب البيانات مع عمل Join للجداول (Courses & Rooms)
      final List<dynamic> response = await supabase
          .from('schedules')
          .select('''
            *,
            courses (*),
            rooms (*)
          ''')
          .eq('user_id', userId);

      // تحويل البيانات القادمة إلى List من ScheduleModel
      schedules.value = response
          .map((item) => ScheduleModel.fromJson(item))
          .toList();

      // تحديد المحاضرة القادمة (منطق بسيط للعرض)
      _setUpcomingLecture();
    } catch (e) {
      debugPrint(
        '===== \nError fetching user schedule: in ScheduleController: $e',
      );
      Get.snackbar("خطأ", "فشل جلب الجدول الدراسي: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _setUpcomingLecture() {
    if (schedules.isNotEmpty) {
      // لغرض العرض (Demo)، سنعتبر أول محاضرة في القائمة هي القادمة
      // يمكنك لاحقاً إضافة منطق مقارنة الوقت الحالي بالجدول
      upcomingLecture.value = schedules.first;
    }
  }
}
