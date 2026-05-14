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
  void onReady() {
    super.onReady();
    fetchFullSchedule();
  }

  Future<void> fetchFullSchedule() async {
    try {
      isLoading.value = true;
      final userId = authController.currentUser.value!.id;
      final role = authController.currentUser.value!.role;

      dynamic response;

      if (role == 'student') {
        // جلب جداول المواد التي سجل فيها الطالب (Enrollments)
        response = await supabase
            .from('schedules')
            .select(
              '*, courses!inner(course_name, course_code, professor_id, enrollments!inner(student_id)), rooms(*)',
            )
            .eq('courses.enrollments.student_id', userId);
      } else {
        // جلب جداول المواد التي يدرسها الدكتور
        response = await supabase
            .from('schedules')
            .select(
              '*, courses!inner(course_name, course_code, professor_id), rooms(*)',
            )
            .eq('courses.professor_id', userId);
      }

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
    print('======\nGrouped Schedule: $weeklySchedule');
  }
}
