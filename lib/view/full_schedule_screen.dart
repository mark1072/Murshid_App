import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../controllers/full_schedule_controller.dart';
import '../controllers/course_note_controller.dart';
import '../controllers/auth_controller.dart';

class FullScheduleScreen extends StatelessWidget {
  FullScheduleScreen({super.key});
  final controller = Get.put(FullScheduleController());
  final courseNoteController = Get.put(CourseNoteController());

  @override
  Widget build(BuildContext context) {
    final List<String> days = [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
    ];
    final List<String> dayKeys = [
      'day_saturday',
      'day_sunday',
      'day_monday',
      'day_tuesday',
      'day_wednesday',
      'day_thursday',
    ];

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text('full_schedule'.tr),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.accent,
            tabs: dayKeys.map((key) => Tab(text: key.tr)).toList(),
          ),
        ),

        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: days.map((day) => _buildDayList(day)).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildDayList(String day) {
    var dayLectures = controller.weeklySchedule[day] ?? [];
    if (dayLectures.isEmpty) {
      return Center(child: Text('no_lectures_on_day'.tr));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayLectures.length,
      itemBuilder: (context, index) {
        final lecture = dayLectures[index];
        // make the card clickable to show the note dialog

        return InkWell(
          onTap: () {
            print('=====\nLecture tapped: $lecture');
            print('=====\nLecture tapped: ${lecture['course_id']}');
            _showNoteDialog(
              context,
              lecture['courses']['course_name'],
              lecture['courses']['course_code'],
              lecture['course_id'],
              lecture['courses']['professor_id'],
              courseNoteController,
            );
          },
          child: Card(
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
                "${'hall_label'.tr} ${lecture['rooms']['room_number']} - ${lecture['rooms']['building_name']}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ),
        );
      },
    );
  }
}

void _showNoteDialog(
  BuildContext context,
  String courseName,
  String courseCode,
  int courseId,
  String professorId,
  CourseNoteController noteController,
) {
  final noteTextController = TextEditingController();

  Get.defaultDialog(
    titlePadding: const EdgeInsets.all(20),
    contentPadding: const EdgeInsets.all(20),
    title: 'ملاحظة عن المقرر',
    titleStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'المقرر: $courseName ($courseCode)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        TextField(
          controller: noteTextController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'اكتب ملاحظتك هنا',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: 'مثال: لدي استفسار عن الدرس...',
          ),
          textAlign: TextAlign.right,
        ),
      ],
    ),
    cancel: OutlinedButton.icon(
      icon: const Icon(Icons.close),
      label: const Text('إلغاء'),
      onPressed: () => Get.back(),
    ),
    confirm: Obx(
      () => ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: Text(
          noteController.isLoading.value ? 'جاري الإرسال...' : 'إرسال',
        ),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        onPressed: noteController.isLoading.value
            ? null
            : () async {
                if (noteTextController.text.trim().isEmpty) {
                  Get.snackbar(
                    'تنبيه',
                    'الرجاء كتابة ملاحظة قبل الإرسال',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                  return;
                }

                final success = await noteController.sendNoteToTeacher(
                  professorId: professorId,
                  courseId: courseId,
                  courseCode: courseCode,
                  courseName: courseName,
                  noteText: noteTextController.text.trim(),
                );

                if (success) {
                  Get.back();
                  noteTextController.clear();
                  Get.snackbar(
                    'success'.tr,
                    'note_sent_successfully'.tr,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'error'.tr,
                    'failed_to_send_note'.tr,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
      ),
    ),
  );
}
