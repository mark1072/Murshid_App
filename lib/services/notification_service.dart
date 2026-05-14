import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';

class NotificationService extends GetxService {
  final supabase = Supabase.instance.client;
  var unreadNotificationsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _requestNotificationPermissions();
    _listenToNotifications();
  }

  // Request notification permissions (especially for Android 13+)
  Future<void> _requestNotificationPermissions() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  void _listenToNotifications() {
    // تشغيل خاصية الـ Realtime على جدول التنبيهات
    supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) async {
            // استخراج البيانات من الـ Payload
            final senderId = payload.newRecord['sender_id'];
            final title = payload.newRecord['title'];
            final message = payload.newRecord['message'];
            final courseId = payload.newRecord['course_id'];

            final authController = Get.find<AuthController>();
            final currentUser = authController.currentUser.value;

            // إذا لم يكن هناك مستخدم مسجل الدخول، تجاهل الإشعار
            if (currentUser == null) return;

            // إذا كان المستخدم هو مرسل الإشعار (الدكتور)، تجاهل إظهار الإشعار المحلي
            if (senderId == currentUser.id) return;

            // إذا كان الإشعار مخصصاً لمادة معينة، تحقق من تسجيل الطالب فيها
            if (courseId != null) {
              try {
                final enrollment = await supabase
                    .from('enrollments')
                    .select()
                    .eq('student_id', currentUser.id)
                    .eq('course_id', courseId)
                    .maybeSingle();

                if (enrollment == null) {
                  // الطالب غير مسجل في المادة، تجاهل الإشعار
                  return;
                }
              } catch (e) {
                debugPrint('Error checking enrollment for notification: $e');
                return;
              }
            }

            // زيادة عدد التنبيهات غير المقروءة
            unreadNotificationsCount.value++;

            // إظهار التنبيه على هاتف الطالب
            _showLocalNotification(title, message);
          },
        )
        .subscribe();
  }

  void _showLocalNotification(String title, String message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'alerts',
        title: title,
        body: message,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }


  // Mark notifications as read
  void markNotificationsAsRead() {
    unreadNotificationsCount.value = 0;
  }

  // Push notification to a specific user
  Future<void> pushNotificationToUser({
    required String recipientId,
    required String title,
    required String message,
    required String notificationType,
  }) async {
    try {
      // Save notification to database with recipient_id
      await supabase.from('notifications').insert({
        'recipient_id': recipientId,
        'title': title,
        'message': message,
        'notification_type': notificationType,
      });

      debugPrint('Notification sent to user: $recipientId');
    } catch (e) {
      debugPrint('Error pushing notification to user: $e');
    }
  }
}
