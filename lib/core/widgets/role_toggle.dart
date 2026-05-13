import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

class RoleToggle extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleToggle({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  static const double pillWidth = 200;
  static const double pillHeight = 44;

  @override
  Widget build(BuildContext context) {
    final isStudent = selectedRole == 'student';

    return Center(
      child: GestureDetector(
        onTap: () {
          onChanged(isStudent ? 'professor' : 'student');
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
              // Sliding thumb
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment:
                    isStudent ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                child: Container(
                  width: pillWidth / 2 + 4,
                  height: pillHeight - 4,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(pillHeight / 2),
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Labels row
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color: !isStudent ? Colors.white : AppColors.textDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'professor'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  !isStudent ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school,
                            size: 18,
                            color: isStudent ? Colors.white : AppColors.textDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'student'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isStudent ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
