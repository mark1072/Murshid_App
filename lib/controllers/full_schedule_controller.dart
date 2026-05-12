import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_controller.dart';

class FullScheduleController extends GetxController {
  final supabase = Supabase.instance.client;
  final authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var weeklySchedule =
      <String, List<dynamic>>{}.obs; // تجميع البيانات حسب اليوم

  @override
  void onInit() {
    super.onInit();
    fetchFullSchedule();
  }

  Future<void> fetchFullSchedule() async {
    try {
      isLoading.value = true;
      final userId = authController.currentUser.value!.id;

      // Simple direct query using user_id as per database schema
      final response = await supabase
          .from('schedules')
          .select('*, courses(id, course_name, course_code), rooms(*)')
          .eq('user_id', userId);

      _groupByDay(response);
    } catch (e) {
      Get.snackbar("Error", "Failed to load schedule");
    } finally {
      isLoading.value = false;
    }
  }

  // تقسيم البيانات: {'Sunday': [...], 'Monday': [...]}
  void _groupByDay(List<dynamic> data) {
    Map<String, List<dynamic>> tempMap = {
      'Sunday': [],
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
    };

    for (var item in data) {
      String day = item['day_of_week'];
      if (tempMap.containsKey(day)) {
        tempMap[day]!.add(item);
      }
    }
    weeklySchedule.value = tempMap;
  }
}
