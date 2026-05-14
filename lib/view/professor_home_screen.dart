// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/professor_controller.dart';

class ProfessorHomeScreen extends StatefulWidget {
  const ProfessorHomeScreen({super.key});

  @override
  State<ProfessorHomeScreen> createState() => _ProfessorHomeScreenState();
}

class _ProfessorHomeScreenState extends State<ProfessorHomeScreen> {
  final controller = Get.put(ProfessorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'faculty_portal'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
        // Language switch button
        _buildLanguageButton(),
        IconButton(
          onPressed: () {
            Get.find<AuthController>().logout();
            Get.offAllNamed("/login");
          },
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: controller.professorSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = controller.professorSchedules[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Text(
                        schedule.course.courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${schedule.startTime} | ${schedule.room.fullLocation}",
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _showNotifyDialog(
                          context,
                          schedule.course.courseName,
                          schedule.course.id,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: Text(
                          'alert_students'.tr,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add_course'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // نافذة إدخال التنبيه
  void _showNotifyDialog(BuildContext context, String courseName, int courseId) {
    final titleController = TextEditingController(text: "${'alert_prefix'.tr} $courseName");
    final msgController = TextEditingController();

    Get.defaultDialog(
      title: 'send_quick_alert'.tr,
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'alert_title'.tr),
          ),
          TextField(
            controller: msgController,
            decoration: InputDecoration(labelText: 'alert_message'.tr),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: 'send'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.sendAlert(titleController.text, msgController.text, courseId);
        Get.back();
      },
    );
  }

  // Language switch button for the AppBar
  Widget _buildLanguageButton() {
    final isArabic = (Get.locale?.languageCode ?? 'ar') == 'ar';
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        if (isArabic) {
          await prefs.setString('lang', 'en');
          await prefs.setString('country', 'US');
          Get.updateLocale(const Locale('en', 'US'));
        } else {
          await prefs.setString('lang', 'ar');
          await prefs.setString('country', 'EG');
          Get.updateLocale(const Locale('ar', 'EG'));
        }
      },
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            isArabic ? 'E' : '\u0639',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
