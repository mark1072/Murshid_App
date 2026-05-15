import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_controller.dart';
import '../services/connectivity_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FullScheduleController extends GetxController {
  final supabase = Supabase.instance.client;
  final authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var weeklySchedule =
      <String, List<dynamic>>{}.obs; // تجميع البيانات حسب اليوم

  @override
  void onReady() {
    super.onReady();
    fetchFullSchedule();
  }

  Future<void> fetchFullSchedule() async {
    try {
      isLoading.value = true;
      final userId = authController.currentUser.value!.id;
      final connectivity = Get.find<ConnectivityService>();
      if (connectivity.isConnected.value) {
        // Online: fetch from API
        final response = await supabase
            .from('schedules')
            .select('*, courses(id, course_name, course_code), rooms(*)')
            .eq('user_id', userId);
        // حفظ البيانات في Hive
        final box = await Hive.openBox('schedule');
        await box.put('full_user_$userId', response);
        _groupByDay(response);
      } else {
        // Offline: جلب البيانات من Hive
        final box = await Hive.openBox('schedule');
        final cached = box.get('full_user_$userId');
        if (cached != null) {
          _groupByDay(List<Map<String, dynamic>>.from(cached));
        }
      }
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
