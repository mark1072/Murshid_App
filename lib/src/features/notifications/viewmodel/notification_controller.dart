import 'package:get/get.dart';
import 'package:musrshid_app/src/core/services/connectivity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';

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
      final connectivity = Get.find<ConnectivityService>();
      if (connectivity.isConnected.value) {
        // Online: fetch from API
        final data = await supabase
            .from('notifications')
            .select('*, profiles(full_name)')
            .order('created_at', ascending: true);
        // حفظ البيانات في Hive
        final box = await Hive.openBox('notifications');
        await box.put('all', data);
        notifications.assignAll(data);
      } else {
        // Offline: جلب البيانات من Hive
        final box = await Hive.openBox('notifications');
        final cached = box.get('all');
        if (cached != null) {
          notifications.assignAll(List<Map<String, dynamic>>.from(cached));
        }
      }
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
