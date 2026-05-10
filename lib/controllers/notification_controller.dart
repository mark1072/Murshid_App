import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Fetching and ordering by the most recent first
      final data = await supabase
          .from('notifications')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: true);

      notifications.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Could not load notifications");
    } finally {
      isLoading.value = false;
    }
  }
}
