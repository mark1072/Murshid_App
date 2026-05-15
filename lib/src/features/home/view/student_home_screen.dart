// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musrshid_app/src/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musrshid_app/src/features/schedule/viewmodel/schedule_controller.dart';
import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_sizes.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/features/courses/viewmodel/course_note_controller.dart';
import 'package:musrshid_app/src/core/services/navigation_service.dart';
import 'package:musrshid_app/src/core/services/notification_service.dart';
import 'package:musrshid_app/src/core/services/connectivity_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  // استدعاء الـ Controller
  final scheduleController = Get.put(ScheduleController());
  final authController = Get.find<AuthController>();
  late ConnectivityService connectivityService;

  @override
  void initState() {
    super.initState();
    connectivityService = Get.find<ConnectivityService>();
    _bindUserData();

    // الاستماع لتغييرات الاتصال وعرض الرسائل
    connectivityService.isConnected.listen((isConnected) {
      if (!isConnected) {
        // عرض رسالة عندما يكون لا يوجد اتصال
        Get.snackbar(
          'no_connection'.tr,
          'no_internet_message'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.wifi_off, color: Colors.white),
        );
      } else {
        // عرض رسالة النجاح عند استرجاع الاتصال
        Get.snackbar(
          'connected'.tr,
          'connection_restored'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.wifi, color: Colors.white),
        );
      }
    });
  }

  // function to store the current user data in storage service
  void _storeUserData() async {
    final user = authController.currentUser.value;
    if (user != null) {
      await Get.find<StorageService>().saveUser(user);
    }
  }

  void _bindUserData() {
    // restore cached profile if the auth controller has not been hydrated yet
    if (authController.currentUser.value == null) {
      final cachedUser = Get.find<StorageService>().getCachedUser();
      if (cachedUser != null) {
        authController.currentUser.value = cachedUser;
      }
    }

    // save immediately if user info is already available
    if (authController.currentUser.value != null) {
      _storeUserData();
    }

    // save whenever the authenticated user updates
    ever(authController.currentUser, (_) {
      if (authController.currentUser.value != null) {
        _storeUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        // حالة التحميل
        if (scheduleController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            // شريط تنبيه عند عدم الاتصال
            Obx(() {
              if (!connectivityService.isConnected.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'no_internet_banner'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // المحتوى الرئيسي
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 25),
                    _buildUpcomingCard(),
                    const SizedBox(height: 25),
                    _buildSectionTitle('today'.tr),
                    const SizedBox(height: 15),
                    _buildTodaySchedule(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 1. بناء الـ AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'app_name'.tr,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.logout, color: AppColors.primary),
        onPressed: () => Get.find<AuthController>().logout(), // تسجيل الخروج
      ),
      actions: [
        // Language switch button
        _buildLanguageButton(),
        Obx(() {
          final notificationService = Get.find<NotificationService>();
          final unreadCount =
              notificationService.unreadNotificationsCount.value;
          return Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () {
                  notificationService.markNotificationsAsRead();
                  Get.toNamed('/notifications');
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(width: 10),
      ],
    );
  }

  // 2. بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        TextButton(
          onPressed: () {
            // show all schedules in a new screen
            Get.toNamed('/full_schedule');
          }, // عرض الجدول الكامل
          child: Text(
            'view_all'.tr,
            style: const TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  // 3. بناء قائمة جدول اليوم
  Widget _buildTodaySchedule() {
    return Obx(() {
      if (scheduleController.schedules.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('no_lectures_today'.tr),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true, // مهم جداً لأنها داخل SingleChildScrollView
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scheduleController.schedules.length,
        itemBuilder: (context, index) {
          final item = scheduleController.schedules[index];
          final noteController = Get.put(CourseNoteController());

          return GestureDetector(
            onTap: () {
              // عند الضغط، إظهار dialog لكتابة ملاحظة
              if (item.professorId != null) {
                _showNoteDialog(
                  context,
                  item.course.courseName,
                  item.course.courseCode,
                  item.course.id,
                  item.professorId!,
                  noteController,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.r16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // عمود الوقت
                  Column(
                    children: [
                      Text(
                        item.startTime.substring(0, 5), // عرض HH:mm فقط
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_downward,
                        size: 12,
                        color: Colors.grey,
                      ),
                      Text(
                        item.endTime.substring(0, 5),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // خط فاصل ملون
                  Container(width: 3, height: 40, color: AppColors.accent),
                  const SizedBox(width: 15),
                  // بيانات المادة والقاعة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.course.courseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.room.buildingName} - ${item.room.roomNumber}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // أيقونة الملاحة السريعة
                  IconButton(
                    icon: const Icon(
                      Icons.directions_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: () => NavigationService().openMapToDestination(
                      item.room.latitude ?? 0.0,
                      item.room.longitude ?? 0.0,
                    ),
                    // Get.toNamed('/navigation_map', arguments: item.room),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // الجزء العلوي (الترحيب)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'academic_portal'.tr,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 26,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: "${'welcome_greeting'.tr} \n"),
              TextSpan(
                // get user name from auth controller
                text:
                    authController.currentUser.value?.fullName ??
                    'default_student'.tr,
                style: TextStyle(color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // الكرت الكحلي (المحاضرة القادمة)
  Widget _buildUpcomingCard() {
    final lecture = scheduleController.upcomingLecture.value;

    if (lecture == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.r25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge('upcoming_lecture'.tr),
          const SizedBox(height: 15),
          Text(
            lecture.course.courseName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            lecture.course.courseCode,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                'time_label'.tr,
                "${lecture.startTime} - ${lecture.endTime}",
              ),
              _buildInfoTile(
                'location_label'.tr,
                "${lecture.room.buildingName} • ${lecture.room.roomNumber}",
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // سيتم ربطه بصفحة الخريطة لاحقاً
              NavigationService().openMapToDestination(
                lecture.room.latitude ?? 0.0,
                lecture.room.longitude ?? 0.0,
              );
              // Get.toNamed('/navigation_map', arguments: lecture.room);
            },
            icon: const Icon(Icons.near_me, size: 18),
            label: Text('start_guidance'.tr),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // وظائف مساعدة لبناء الواجهة
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            isArabic ? 'E' : 'ع',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                  }
                },
        ),
      ),
    );
  }
}
