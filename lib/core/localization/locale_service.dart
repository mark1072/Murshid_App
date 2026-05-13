import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static Future<void> changeLanguage(String langCode, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);
    await prefs.setString('country', countryCode);
    Get.updateLocale(Locale(langCode, countryCode));
  }
}
