import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late Box _authBox;
  late Box _scheduleBox;

  Future<StorageService> init() async {
    _authBox = Hive.box('auth');
    _scheduleBox = Hive.box('schedule');
    return this;
  }

  // Save user data locally
  Future<void> saveUser(UserModel user) async {
    await _authBox.put('current_user', user.toJson());
  }

  // Get cached user data
  UserModel? getCachedUser() {
    final userData = _authBox.get('current_user');
    if (userData != null) {
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  // Clear user data
  Future<void> clearUser() async {
    await _authBox.delete('current_user');
  }

  // Save selected courses for student
  Future<void> saveStudentCourses(List<int> courseIds) async {
    await _authBox.put('student_courses', courseIds);
  }

  // Get cached student courses
  List<int> getStudentCourses() {
    final courses = _authBox.get('student_courses') as List<dynamic>?;
    return courses?.cast<int>() ?? [];
  }

  // Save professor courses
  Future<void> saveProfessorCourses(List<int> courseIds) async {
    await _authBox.put('professor_courses', courseIds);
  }

  // Get cached professor courses
  List<int> getProfessorCourses() {
    final courses = _authBox.get('professor_courses') as List<dynamic>?;
    return courses?.cast<int>() ?? [];
  }

  // Clear all cached data
  Future<void> clearAll() async {
    await _authBox.clear();
    await _scheduleBox.clear();
  }
}
