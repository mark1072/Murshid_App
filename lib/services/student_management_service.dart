import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class StudentManagementService extends GetxService {
  final supabase = Supabase.instance.client;

  var students = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllStudents();
  }

  // Fetch all students from database
  Future<void> fetchAllStudents() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('role', 'student')
          .order('full_name');

      students.value = response
          .map((item) => UserModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('===== \nError fetching students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add students to a course
  Future<void> addStudentsToSchedule(
    List<String> studentIds,
    int courseId,
  ) async {
    try {
      // if courseId is already exists update the existing schedule with new students
      final existingSchedule = await supabase
          .from('schedules')
          .select('*')
          .eq('course_id', courseId);
      if (existingSchedule.isNotEmpty) {
        for (String studentId in studentIds) {
          await supabase.from('enrollments').update({
            'student_id': studentId,
            'course_id': courseId,
          });
        }
        return;
      }
      for (String studentId in studentIds) {
        await supabase.from('enrollments').insert({
          'student_id': studentId,
          'course_id': courseId,
        });
      }
    } catch (e) {
      debugPrint('===== \nError adding students to schedule: $e');
      rethrow;
    }
  }
}
