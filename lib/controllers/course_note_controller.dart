import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_note_model.dart';
import '../services/notification_service.dart';
import 'auth_controller.dart';

class CourseNoteController extends GetxController {
  final supabase = Supabase.instance.client;
  final AuthController _authController = Get.find<AuthController>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  var isLoading = false.obs;
  var notes = <CourseNoteModel>[].obs;
  var unreadNotesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotes();
  }

  // إرسال ملاحظة من الطالب إلى المدرس
  Future<bool> sendNoteToTeacher({
    required String professorId,
    required int courseId,
    required String courseCode,
    required String courseName,
    required String noteText,
  }) async {
    try {
      isLoading.value = true;
      final studentId = _authController.currentUser.value!.id;
      final studentName = _authController.currentUser.value!.fullName;

      // حفظ الملاحظة في قاعدة البيانات
      await supabase.from('course_notes').insert({
        'student_id': studentId,
        'professor_id': professorId,
        'course_id': courseId,
        'course_code': courseCode,
        'course_name': courseName,
        'note_text': noteText,
        'is_read': false,
      });

      // إرسال إشعار للمدرس
      await _notificationService.pushNotificationToUser(
        recipientId: professorId,
        title: 'ملاحظة جديدة من الطالب',
        message: '$studentName: $noteText',
        notificationType: 'course_note',
      );

      Get.snackbar(
        'تم الإرسال',
        'تم إرسال ملاحظتك إلى المدرس بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('===== \nError sending note: $e');
      Get.snackbar(
        'خطأ',
        'فشل إرسال الملاحظة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // جلب الملاحظات للمدرس
  Future<void> fetchNotesForProfessor() async {
    try {
      isLoading.value = true;
      final professorId = _authController.currentUser.value!.id;

      final response = await supabase
          .from('course_notes')
          .select('*')
          .eq('professor_id', professorId)
          .order('created_at', ascending: false);

      notes.value = response
          .map((item) => CourseNoteModel.fromJson(item))
          .toList();

      // عد الملاحظات غير المقروءة
      unreadNotesCount.value = notes.where((note) => !note.isRead).length;
    } catch (e) {
      debugPrint('Error fetching professor notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // الاستماع لالملاحظات الجديدة (Real-time)
  void _listenToNotes() {
    final role = _authController.currentUser.value?.role;
    if (role == 'professor') {
      final professorId = _authController.currentUser.value!.id;

      supabase
          .channel('public:course_notes')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'course_notes',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'professor_id',
              value: professorId,
            ),
            callback: (payload) {
              final newNote = CourseNoteModel.fromJson(payload.newRecord);
              notes.insert(0, newNote);
              unreadNotesCount.value++;
              debugPrint('ملاحظة جديدة مستلمة: ${newNote.noteText}');
            },
          )
          .subscribe();
    }
  }

  // تحديث حالة القراءة
  Future<void> markNoteAsRead(int noteId) async {
    try {
      await supabase
          .from('course_notes')
          .update({'is_read': true})
          .eq('id', noteId);

      final index = notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        final updatedNote = notes[index];
        notes[index] = CourseNoteModel(
          id: updatedNote.id,
          studentId: updatedNote.studentId,
          professorId: updatedNote.professorId,
          courseId: updatedNote.courseId,
          courseCode: updatedNote.courseCode,
          courseName: updatedNote.courseName,
          noteText: updatedNote.noteText,
          createdAt: updatedNote.createdAt,
          isRead: true,
          studentName: updatedNote.studentName,
          professorName: updatedNote.professorName,
        );
        unreadNotesCount.value--;
      }
    } catch (e) {
      debugPrint('Error marking note as read: $e');
    }
  }

  // حذف ملاحظة
  Future<void> deleteNote(int noteId) async {
    try {
      await supabase.from('course_notes').delete().eq('id', noteId);
      notes.removeWhere((note) => note.id == noteId);
      Get.snackbar(
        'تم الحذف',
        'تم حذف الملاحظة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error deleting note: $e');
      Get.snackbar(
        'خطأ',
        'فشل حذف الملاحظة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
