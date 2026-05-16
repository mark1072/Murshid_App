import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musrshid_app/src/features/schedule/model/schedule_model.dart';

import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';

class ProfessorController extends GetxController {
  final supabase = Supabase.instance.client;
  final AuthController _auth = Get.find<AuthController>();

  var isLoading = false.obs;
  var professorSchedules = <ScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfessorSchedule();
  }

  // جلب محاضرات الدكتور فقط
  Future<void> fetchProfessorSchedule() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('schedules')
          .select('*, courses(*), rooms(*)')
          .eq('user_id', _auth.currentUser.value!.id);

      professorSchedules.value = response
          .map((item) => ScheduleModel.fromJson(item))
          .toList();

      // final response = await supabase
      //     .from('schedules')
      //     .select('*, courses(*), rooms(*)')
      //     .eq('courses.professor_id', _auth.currentUser.value!.id);

      // debugPrint('===== \nProfessor schedule response: $response');

      // professorSchedules.value = response
      //     .map((item) => ScheduleModel.fromJson(item))
      //     .toList();
    } catch (e) {
      debugPrint('===== \nError fetching professor schedule: $e');
      Get.snackbar("خطأ", "فشل جلب الجدول");
    } finally {
      isLoading.value = false;
    }
  }

  // إرسال تنبيه للطلاب
  Future<void> sendAlert(String title, String message, int courseId) async {
    try {
      // Send notification to all students enrolled in the course
      final studentsResponse = await supabase
          .from('enrollments')
          .select('student_id')
          .eq('course_id', courseId);
      final studentIds = studentsResponse
          .map((item) => item['student_id'])
          .toList();

      for (final studentId in studentIds) {
        await supabase.from('notifications').insert({
          'sender_id': _auth.currentUser.value!.id,
          'title': title,
          'message': message,
          'recipient_id': studentId,
          'course_id': courseId,
        });
      }
      // // Save notification to database
      // await supabase.from('notifications').insert({
      //   'sender_id': _auth.currentUser.value!.id,
      //   'title': title,
      //   'message': message,
      //   'course_id': courseId,
      // });

      Get.snackbar(
        "تم الإرسال",
        // "تم إرسال التنبيه لجميع الطلاب بنجاح",
        // "Alert sent successfully to students enrolled in the course",
        'note_sent_successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('===== \nError sending alert: $e');
      Get.snackbar("خطأ", "فشل إرسال التنبيه: $e");
    }
  }
}
