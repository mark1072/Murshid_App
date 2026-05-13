import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musrshid_app/view/professor_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_colors.dart';
import 'controllers/auth_controller.dart';
import 'core/localization/app_translations.dart';
import 'services/notification_service.dart';
import 'services/course_service.dart';
import 'services/room_service.dart';
import 'services/student_management_service.dart';
import 'services/connectivity_service.dart';
import 'view/course_selection_screen.dart';
import 'view/add_course_screen.dart';
import 'view/full_schedule_screen.dart';
import 'view/login_screen.dart';
import 'view/notification_screen.dart';
import 'view/signup_screen.dart';
import 'view/student_home_screen.dart';
import 'view/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await initializeDateFormatting('ar', null);


  await Supabase.initialize(
    url: 'https://ieatgqyzhhminsuavsss.supabase.co',
    anonKey: 'sb_publishable_WFtIIPKgfehm4ZVJM0l27w_6CD21t0v',
  );

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'alerts',
        channelName: 'Murshid Alerts',
        channelDescription: 'تنبيهات المحاضرات والجدول الدراسية',
        defaultColor: AppColors.primary,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
      ),
    ],
  );

  Get.put(AuthController(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(CourseService(), permanent: true);
  Get.put(RoomService(), permanent: true);
  Get.put(StudentManagementService(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);

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
      title: 'Murshid Smart Assistant',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: locale,
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
        GetPage(name: '/full_schedule', page: () => FullScheduleScreen()),
      ],
    );
  }
}

//student@murshid.com
//student123456

//professor@murshid.com
//prof123456

//ra@hotmil.com
//new123

//ra2@hotmil.com
//new1234

//new2@hotmil.com
//new12345

// to upload to github
// git init
// git remote add origin https://github.com/Hotmil/Murshid.git
// git add .
// git commit -m "message"
// git push
// to git local branch
// to know your local branch name
// git branch
