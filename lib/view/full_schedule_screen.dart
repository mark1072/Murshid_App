import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../controllers/full_schedule_controller.dart';

class FullScheduleScreen extends StatelessWidget {
  const FullScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FullScheduleController());

    final List<String> days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
    ];
    final List<String> daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
    ];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الجدول الدراسي الكامل"),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.accent,
            tabs: daysAr.map((day) => Tab(text: day)).toList(),
          ),
        ),
        body: TabBarView(
          children: days.map((day) => _buildDayList(controller, day)).toList(),
        ),
      ),
    );
  }

  Widget _buildDayList(FullScheduleController controller, String day) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      var dayLectures = controller.weeklySchedule[day] ?? [];

      if (dayLectures.isEmpty) {
        return Center(child: Text("لا توجد محاضرات في يوم $day"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dayLectures.length,
        itemBuilder: (context, index) {
          final lecture = dayLectures[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lecture['start_time'].toString().substring(0, 5),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              title: Text(lecture['courses']['course_name']),
              subtitle: Text(
                "قاعة: ${lecture['rooms']['room_number']} - ${lecture['rooms']['building_name']}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          );
        },
      );
    });
  }
}
