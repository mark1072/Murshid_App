import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/core/services/connectivity_service.dart';
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
      final box = Hive.box('schedule');

      if (connectivity.isConnected.value) {
        // Online: fetch from API
        final response = await supabase
            .from('schedules')
            .select(
              '*, courses!inner(course_name, course_code, enrollments!inner(student_id)), rooms(*)',
            )
            .eq('courses.enrollments.student_id', userId);
        // حفظ البيانات في Hive
        await box.put('full_user_$userId', response);
        _groupByDay(response);
      } else {
        // Offline: جلب البيانات من Hive
        final cached = box.get('full_user_$userId');
        if (cached != null) {
          _groupByDay(List<dynamic>.from(cached));
        } else {
          weeklySchedule.clear();
          Get.snackbar(
            "تنبيه",
            "لا توجد بيانات محفوظة",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint("======\nError fetching full schedule: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // تقسيم البيانات: {'Sunday': [...], 'Monday': [...]}
  void _groupByDay(List<dynamic> data) {
    Map<String, List<dynamic>> tempMap = {
      'Saturday': [],
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
    debugPrint('======\nGrouped Schedule: $weeklySchedule');
  }
}
