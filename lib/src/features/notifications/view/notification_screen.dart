// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:musrshid_app/src/features/notifications/viewmodel/notification_controller.dart';
import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_theme.dart';
import 'package:musrshid_app/src/core/widgets/custom_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "مركز التنبيهات"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.notifications.isEmpty) {
          return EmptyState(
            icon: Icons.notifications_off_outlined,
            title: 'no_notifications'.tr,
            message: 'no_notifications_message'.tr,
            onRetry: controller.fetchNotifications,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final item = controller.notifications[index];
              return _buildNotificationItem(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data) {
    DateTime createdAt = DateTime.parse(data['created_at']);
    String formattedTime = DateFormat('h:mm a').format(createdAt);
    String formattedDate = DateFormat('d MMM y').format(createdAt);

    return CustomCard(
      onTap: () {},
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['title'] ?? 'important_update'.tr,
                  style: AppTheme.headingSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['message'] ?? '',
            style: AppTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "${'from'.tr}: ${data['profiles']?['full_name'] ?? 'department'.tr}",
                  style: AppTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$formattedDate | $formattedTime",
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
