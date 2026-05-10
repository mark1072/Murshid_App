import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late GetStorage _storage;

  @override
  Future<StorageService> onInit() async {
    await GetStorage.init();
    _storage = GetStorage();
    return super.onInit() as Future<StorageService>;
  }

  // Save user data locally
  Future<void> saveUser(UserModel user) async {
    await _storage.write('current_user', user.toJson());
  }

  // Get cached user data
  UserModel? getCachedUser() {
    final userData = _storage.read('current_user');
    if (userData != null) {
      return UserModel.fromJson(userData as Map<String, dynamic>);
    }
    return null;
  }

  // Clear user data
  Future<void> clearUser() async {
    await _storage.remove('current_user');
  }

  // Save selected courses for student
  Future<void> saveStudentCourses(List<int> courseIds) async {
    await _storage.write('student_courses', courseIds);
  }

  // Get cached student courses
  List<int> getStudentCourses() {
    final courses = _storage.read('student_courses') as List<dynamic>?;
    return courses?.cast<int>() ?? [];
  }

  // Save professor courses
  Future<void> saveProfessorCourses(List<int> courseIds) async {
    await _storage.write('professor_courses', courseIds);
  }

  // Get cached professor courses
  List<int> getProfessorCourses() {
    final courses = _storage.read('professor_courses') as List<dynamic>?;
    return courses?.cast<int>() ?? [];
  }

  // Clear all cached data
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
