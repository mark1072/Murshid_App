import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  static const double pillWidth = 100;
  static const double pillHeight = 44;

  Future<void> setLocale(String lang, String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    await prefs.setString('country', country);
    Get.updateLocale(Locale(lang, country));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = (Get.locale?.languageCode ?? 'ar') == 'ar';

    return GestureDetector(
      onTap: () {
        if (isArabic) {
          setLocale('en', 'US');
        } else {
          setLocale('ar', 'EG');
        }
      },
      child: Container(
        width: pillWidth,
        height: pillHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(pillHeight / 2),
          color: const Color(0xFFD6E4F0),
        ),
        child: Stack(
          children: [
            // Sliding blue thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isArabic
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: Container(
                width: pillWidth / 2 + 4,
                height: pillHeight - 4,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(pillHeight / 2),
                  color: const Color(0xFF3B7DD8),
                ),
              ),
            ),
            // Flag icons row
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text('🇬🇧', style: const TextStyle(fontSize: 22)),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('🇪🇬', style: const TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
