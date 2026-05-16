import 'package:flutter/material.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musrshid_app/src/features/courses/model/course_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musrshid_app/src/core/services/connectivity_service.dart';

class CourseService extends GetxService {
  final supabase = Supabase.instance.client;

  final connectivity = Get.put<ConnectivityService>(
    ConnectivityService(),
    permanent: true,
  );
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
      // final connectivity = Get.find<ConnectivityService>();
      final box = Hive.box('coursesBox');

      if (connectivity.isConnected.value) {
        final response = await supabase
            .from('courses')
            .select('*')
            .order('course_name');
        courses.value = response
            .map((item) => CourseModel.fromJson(item))
            .toList();
        await box.put('all', response);
      } else {
        final cached = box.get('all');
        if (cached != null) {
          courses.value = (cached as List)
              .map(
                (item) => CourseModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        } else {
          courses.value = [];
        }
      }
    } catch (e) {
      debugPrint('===== \nError fetching courses: $e');
      courses.value = [];
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
