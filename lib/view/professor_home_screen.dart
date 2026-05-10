import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        title: const Text(
          "بوابة أعضاء هيئة التدريس",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
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
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                        ),
                        child: const Text(
                          "تنبيه الطلاب",
                          style: TextStyle(color: AppColors.primary),
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
  void _showNotifyDialog(BuildContext context, String courseName) {
    final titleController = TextEditingController(text: "تنبيه: $courseName");
    final msgController = TextEditingController();

    Get.defaultDialog(
      title: "إرسال تنبيه سريع",
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "العنوان"),
          ),
          TextField(
            controller: msgController,
            decoration: const InputDecoration(labelText: "رسالة التنبيه"),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: "إرسال",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.sendAlert(titleController.text, msgController.text);
        Get.back();
      },
    );
  }
}
