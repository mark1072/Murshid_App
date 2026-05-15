// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:musrshid_app/src/features/courses/viewmodel/course_note_controller.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_theme.dart';
import 'package:musrshid_app/src/core/widgets/custom_widgets.dart';

class ProfessorNotesScreen extends StatefulWidget {
  const ProfessorNotesScreen({super.key});

  @override
  State<ProfessorNotesScreen> createState() => _ProfessorNotesScreenState();
}

class _ProfessorNotesScreenState extends State<ProfessorNotesScreen> {
  final noteController = Get.put(CourseNoteController());
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // جلب الملاحظات عند دخول الصفحة
    noteController.fetchNotesForProfessor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "ملاحظات الطلاب",
        showBackButton: false,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Badge.count(
                  count: noteController.unreadNotesCount.value,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.mail_outline),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (noteController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (noteController.notes.isEmpty) {
          return EmptyState(
            icon: Icons.mail_outline,
            title: "لا توجد ملاحظات",
            message: "لم يرسل أي طالب ملاحظة حتى الآن",
            onRetry: noteController.fetchNotesForProfessor,
          );
        }

        return RefreshIndicator(
          onRefresh: noteController.fetchNotesForProfessor,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: noteController.notes.length,
            itemBuilder: (context, index) {
              final note = noteController.notes[index];
              return _buildNoteItem(note, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNoteItem(dynamic note, int index) {
    DateTime createdAt = note.createdAt;
    String formattedTime = DateFormat('h:mm a', 'ar').format(createdAt);
    String formattedDate = DateFormat('d MMM y', 'ar').format(createdAt);

    return CustomCard(
      onTap: () {
        if (!note.isRead) {
          noteController.markNoteAsRead(note.id);
        }
      },
      padding: const EdgeInsets.all(16),
      // margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${note.courseName} (${note.courseCode})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من: ${note.studentName ?? "طالب"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: note.isRead
                          ? Colors.grey.shade200
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.mail_outline,
                      size: 20,
                      color: note.isRead ? Colors.grey : AppColors.primary,
                    ),
                  ),
                  if (!note.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          // محتوى الملاحظة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              note.noteText,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          // التاريخ والوقت + أزرار الإجراءات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$formattedDate | $formattedTime",
                style: AppTheme.bodySmall,
              ),
              Row(
                children: [
                  // زر الرد (إذا أردت إضافة رد)
                  TextButton.icon(
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('رد'),
                    onPressed: () {
                      // يمكن إضافة دالة للرد على الملاحظة
                      Get.snackbar(
                        'رد',
                        'يمكنك الرد على الملاحظة لاحقاً',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // زر الحذف
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      'حذف',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'تأكيد الحذف',
                        content: const Text('هل تريد حذف هذه الملاحظة؟'),
                        textConfirm: 'حذف',
                        textCancel: 'إلغاء',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          noteController.deleteNote(note.id);
                          Get.back();
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
