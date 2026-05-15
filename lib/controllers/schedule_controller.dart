import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musrshid_app/services/connectivity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';
import 'auth_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScheduleController extends GetxController {
  // عند إضافة بيانات جديدة أثناء عدم الاتصال
  Future<void> addScheduleOffline(Map<String, dynamic> scheduleData) async {
    final connectivity = Get.find<ConnectivityService>();
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return;
    if (connectivity.isConnected.value) {
      // إذا كان متصل، أضف مباشرة للسيرفر
      await supabase.from('schedules').insert(scheduleData);
      await fetchUserSchedule();
    } else {
      // إذا كان غير متصل، خزّن محلياً وأضف لقائمة المزامنة
      final box = await Hive.openBox('schedule');
      List<dynamic> cached = box.get('user_$userId') ?? [];
      cached.add(scheduleData);
      await box.put('user_$userId', cached);
      _pendingAdditions.add(scheduleData);
      await fetchUserSchedule();
    }
  }

  // قائمة لتخزين العمليات المؤجلة أثناء عدم الاتصال
  final List<Map<String, dynamic>> _pendingAdditions = [];

  final supabase = Supabase.instance.client;

  // نصل لـ AuthController لجلب بيانات المستخدم الحالي
  final AuthController _authController = Get.find<AuthController>();

  // متغيرات الحالة
  var isLoading = false.obs;
  var schedules = <ScheduleModel>[].obs; // قائمة الجدول الدراسي الكاملة
  var upcomingLecture = Rxn<ScheduleModel>(); // المحاضرة القادمة فقط

  @override
  void onInit() {
    super.onInit();
    fetchUserSchedule();
  }

  Future<void> fetchUserSchedule() async {
    try {
      isLoading.value = true;
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final connectivity = Get.find<ConnectivityService>();
      if (connectivity.isConnected.value) {
        // Online: fetch from API
        final List<dynamic> response = await supabase
            .from('schedules')
            .select('*, courses(id, course_name, course_code), rooms(*)')
            .eq('user_id', userId);

        final List<ScheduleModel> all = response
            .map((item) => ScheduleModel.fromJson(item))
            .toList();

        // حفظ البيانات في Hive
        final box = await Hive.openBox('schedule');
        await box.put('user_$userId', response);

        // مزامنة البيانات المؤجلة (إن وجدت)
        if (_pendingAdditions.isNotEmpty) {
          for (final item in _pendingAdditions) {
            // مثال: إرسال البيانات المؤجلة إلى السيرفر
            await supabase.from('schedules').insert(item);
          }
          _pendingAdditions.clear();
        }

        final today = [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
        ][DateTime.now().weekday % 7];
        schedules.value = all.where((s) => s.dayOfWeek == today).toList();
        _setUpcomingLecture();
      } else {
        // Offline: جلب البيانات من Hive
        final box = await Hive.openBox('schedule');
        final cached = box.get('user_$userId');
        if (cached != null) {
          final List<ScheduleModel> all = (cached as List)
              .map(
                (item) =>
                    ScheduleModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
          final today = [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
          ][DateTime.now().weekday % 7];
          schedules.value = all.where((s) => s.dayOfWeek == today).toList();
          _setUpcomingLecture();
        }
      }
    } catch (e) {
      debugPrint(
        '===== \nError fetching user schedule: in ScheduleController: $e',
      );
      Get.snackbar("خطأ", "فشل جلب الجدول الدراسي: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _setUpcomingLecture() {
    if (schedules.isNotEmpty) {
      // لغرض العرض (Demo)، سنعتبر أول محاضرة في القائمة هي القادمة
      // يمكنك لاحقاً إضافة منطق مقارنة الوقت الحالي بالجدول
      upcomingLecture.value = schedules.first;
    }
  }
}
