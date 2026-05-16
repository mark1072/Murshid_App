import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musrshid_app/src/core/services/storage_service.dart';
import 'package:musrshid_app/src/features/home/view/professor_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musrshid_app/src/core/constants/app_colors.dart';
import 'package:musrshid_app/src/core/constants/app_constants.dart';
import 'package:musrshid_app/src/features/auth/viewmodel/auth_controller.dart';
import 'package:musrshid_app/src/core/localization/app_translations.dart';
import 'package:musrshid_app/src/core/services/notification_service.dart';
import 'package:musrshid_app/src/core/services/course_service.dart';
import 'package:musrshid_app/src/core/services/room_service.dart';
import 'package:musrshid_app/src/core/services/student_management_service.dart';
import 'package:musrshid_app/src/core/services/connectivity_service.dart';
import 'package:musrshid_app/src/features/courses/view/course_selection_screen.dart';
import 'package:musrshid_app/src/features/courses/view/add_course_screen.dart';
import 'package:musrshid_app/src/features/schedule/view/full_schedule_screen.dart';
import 'package:musrshid_app/src/features/auth/view/login_screen.dart';
import 'package:musrshid_app/src/features/notifications/view/notification_screen.dart';
import 'package:musrshid_app/src/features/courses/view/professor_notes_screen.dart';
import 'package:musrshid_app/src/features/auth/view/signup_screen.dart';
import 'package:musrshid_app/src/features/home/view/student_home_screen.dart';
import 'package:musrshid_app/src/features/auth/view/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('schedule');
  await Hive.openBox('studentsBox');
  await Hive.openBox('coursesBox');

  await initializeDateFormatting('ar', null);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  NotificationChannel(
    channelKey: 'alerts',
    channelName: 'Murshid Alerts',
    channelDescription: 'تنبيهات المحاضرات والجدول الدراسية',
    defaultColor: AppColors.primary,
    ledColor: Colors.white,
    importance: NotificationImportance.Max,
  );

  try {
    Get.put(AuthController(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(CourseService(), permanent: true);
    Get.put(RoomService(), permanent: true);
    Get.put(StudentManagementService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
  } catch (e) {
    debugPrint('Error putting services: $e');
  }

  try {
    await Get.putAsync<StorageService>(
      () async => await StorageService().init(),
      permanent: true,
    );
  } catch (e) {
    debugPrint('Error initializing StorageService: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('lang') ?? 'ar';
  final country = prefs.getString('country') ?? 'EG';

  runApp(MurshidApp(locale: Locale(lang, country)));
}

class MurshidApp extends StatelessWidget {
  final Locale locale;
  const MurshidApp({super.key, required this.locale});

  String _getInitialRoute() {
    // final user = Supabase.instance.client.auth.currentUser;
    // if (user == null) return '/login';

    // final role = user.userMetadata?['role'];
    // return role == 'professor' ? '/professor_home' : '/student_home';
    return '/splash'; // نبدأ بشاشة Splash أنيقة
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Murshid Smart Assistant',
      locale: locale,
      translations: AppTranslations(),

      fallbackLocale: const Locale('ar', 'EG'),
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: AppColors.background,
      ),

      initialRoute: _getInitialRoute(),

      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(
          name: '/course_selection',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return CourseSelectionScreen(
              userId: args['userId'],
              role: args['role'],
            );
          },
        ),
        GetPage(name: '/student_home', page: () => StudentHomeScreen()),
        GetPage(name: '/professor_home', page: () => ProfessorHomeScreen()),
        GetPage(name: '/add_course', page: () => AddCourseScreen()),
        GetPage(name: '/notifications', page: () => NotificationScreen()),
        GetPage(name: '/professor_notes', page: () => ProfessorNotesScreen()),
        GetPage(name: '/full_schedule', page: () => FullScheduleScreen()),
      ],
    );
  }
}

//mark@gmail.com
//123456789

//student@murshid.com
//student123456

//mo@m.com
//mo1234

//mo2@m.com
//mo1234

//professor@murshid.com
//prof123456

//pro2@p.com
//pro1234

//ra@hotmil.com
//new123

//ra2@hotmil.com
//new1234

//new2@hotmil.com
//new12345
//omarnour@murshed.com --> student
//omarabouzeid@murshed.com --> doctor
//omar##123

// to upload to github
// git init
// git remote add origin https://github.com/Hotmil/Murshid.git
// git add .
// git commit -m "message"
// git push
// to git local branch
// to know your local branch name
// git branch
