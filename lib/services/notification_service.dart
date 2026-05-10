import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          callback: (payload) {
            // استخراج البيانات من الـ Payload
            final title = payload.newRecord['title'];
            final message = payload.newRecord['message'];

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

  // Public method to push notifications to students
  Future<void> pushNotification(String title, String message) async {
    try {
      // Ensure permissions are granted before showing notification
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      unreadNotificationsCount.value++;
      _showLocalNotification(title, message);
    } catch (e) {
      // show snackbar error if notification fails
      debugPrint('===== \nError pushing notification: $e');
      Get.snackbar("خطأ", "فشل إرسال التنبيه", backgroundColor: Colors.red);
    }
  }

  // Mark notifications as read
  void markNotificationsAsRead() {
    unreadNotificationsCount.value = 0;
  }
}
