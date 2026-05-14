import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';

class NotificationController extends GetxController {
  final supabase = Supabase.instance.client;
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        notifications.clear();
        return;
      }

      // Fetch student's enrolled course IDs
      final enrollments = await supabase
          .from('enrollments')
          .select('course_id')
          .eq('student_id', currentUser.id);

      final enrolledCourseIds = enrollments.map((e) => e['course_id']).toList();

      if (enrolledCourseIds.isEmpty) {
        notifications.clear();
        return;
      }

      // Fetching and ordering by the most recent first, filtered by enrolled courses
      final data = await supabase
          .from('notifications')
          .select('*, profiles(full_name)')
          .inFilter('course_id', enrolledCourseIds)
          .order('created_at', ascending: false);

      notifications.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Could not load notifications");
    } finally {
      isLoading.value = false;
    }
  }
}
