import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../services/student_management_service.dart';
import 'auth_controller.dart';

class CourseCreationController extends GetxController {
  final supabase = Supabase.instance.client;
  final authController = Get.find<AuthController>();
  final studentManagementService = Get.find<StudentManagementService>();
  var isLoading = false.obs;
  var courses = <CourseModel>[].obs;

  // Create new course
  Future<int?> createNewCourse({
    required String courseCode,
    required String courseName,
  }) async {
    try {
      isLoading.value = true;
      // check if course code already exists

      final existingCourse = await supabase
          .from('courses')
          .select('*')
          .eq('course_code', courseCode);
      debugPrint('===== \nExisting course check response: $existingCourse');
      if (existingCourse.isNotEmpty) {
        // if course code already exists, update the existing course with new name and professor
        final courseId = existingCourse[0]['id'] as int;
        await supabase
            .from('courses')
            .update({
              'course_name': courseName,
              'professor_id': authController.currentUser.value!.id,
            })
            .eq('id', courseId);
        Get.snackbar('تم التحديث', 'كود المقرر موجود بالفعل');
        return courseId;
      }
      debugPrint(
        '===== \nCreating course with code: $courseCode and name: $courseName',
      );
      final response = await supabase.from('courses').insert({
        'course_code': courseCode,
        'course_name': courseName,
        'professor_id': authController.currentUser.value!.id,
      }).select();
      debugPrint('===== \nCourse creation response: $response');
      if (response.isNotEmpty) {
        Get.snackbar('نجاح', 'تم إنشاء المقرر بنجاح');
        return response[0]['id'] as int;
      }
      return null;
    } catch (e) {
      debugPrint('===== \nError creating course: $e');
      Get.snackbar('خطأ', 'فشل إنشاء المقرر: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Create new schedule (lecture session)
  Future<int?> createSchedule({
    required int courseId,
    required int roomId,
    required String startTime,
    required String endTime,
    required String dayOfWeek,
    required List<String> studentIds,
  }) async {
    try {
      isLoading.value = true;
      // check if course code already exists update the schedule if it does
      final existingSchedule = await supabase
          .from('schedules')
          .select('*')
          .eq('course_id', courseId);
      print('===== \nExisting schedule check response: $existingSchedule');
      if (existingSchedule.isNotEmpty) {
        final scheduleId = existingSchedule[0]['id'] as int;
        await supabase
            .from('schedules')
            .update({
              'room_id': roomId,
              'user_id': authController.currentUser.value!.id,
              'start_time': startTime,
              'end_time': endTime,
              'day_of_week': dayOfWeek,
            })
            .eq('id', scheduleId);
        await studentManagementService.addStudentsToSchedule(
          studentIds,
          courseId,
        );
        Get.snackbar('تم التحديث', 'الجدول موجود بالفعل');
        return scheduleId;
      }
      final response = await supabase.from('schedules').insert({
        'course_id': courseId,
        'room_id': roomId,
        'user_id': authController.currentUser.value!.id,
        'start_time': startTime,
        'end_time': endTime,
        'day_of_week': dayOfWeek,
      }).select();

      if (response.isNotEmpty) {
        // Add students to the schedule using the enrollments table
        // We can use the StudentManagementService to handle this logic
        // This will create entries in the enrollments table linking students to the schedule
        // final scheduleId = response[0]['id'] as int;
        // courseId is needed to link the enrollment to the correct course
        final courseId = response[0]['course_id'] as int;
        await studentManagementService.addStudentsToSchedule(
          studentIds,
          courseId,
        );

        Get.snackbar('نجاح', 'تم إنشاء الجدول بنجاح');
        return response[0]['id'] as int;
      }
      return null;
    } catch (e) {
      debugPrint(
        '===== \nError creating schedule:  in coursse creation controller: $e',
      );
      Get.snackbar('خطأ', 'فشل إنشاء الجدول: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
