import 'package:flutter/material.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

class CourseService extends GetxService {
  final supabase = Supabase.instance.client;

  var courses = <CourseModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCourses();
  }

  // Fetch all available courses
  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('courses')
          .select('*')
          .order('course_name');

      courses.value = response
          .map((item) => CourseModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('===== \nError fetching courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Enroll student in courses using enrollments table
  Future<void> enrollStudentInCourses(
    String userId,
    List<int> courseIds,
  ) async {
    try {
      for (int courseId in courseIds) {
        await supabase.from('enrollments').insert({
          'student_id': userId,
          'course_id': courseId,
          'enrollment_date': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint(
        '===== \nError enrolling student in courses: in course service $e ',
      );
      rethrow;
    }
  }

  // Assign professor to courses
  Future<void> assignProfessorToCourses(
    String professorId,
    List<int> courseIds,
  ) async {
    try {
      for (int courseId in courseIds) {
        await supabase.from('professor_courses').insert({
          'professor_id': professorId,
          'course_id': courseId,
        });
      }
    } catch (e) {
      debugPrint('===== \nError assigning professor to courses: $e');
      rethrow;
    }
  }
}
