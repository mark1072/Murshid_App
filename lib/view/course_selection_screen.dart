// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../services/course_service.dart';

class CourseSelectionScreen extends StatefulWidget {
  final String userId;
  final String role; // 'student' or 'professor'

  const CourseSelectionScreen({
    required this.userId,
    required this.role,
    super.key,
  });

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final courseService = Get.find<CourseService>();
  final Set<int> selectedCourses = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.role == 'student' ? 'اختر المقررات' : 'اختر المقررات للتدريس',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Obx(() {
        if (courseService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (courseService.courses.isEmpty) {
          return const Center(child: Text('لا توجد مقررات متاحة'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: courseService.courses.length,
                itemBuilder: (context, index) {
                  final course = courseService.courses[index];
                  final isSelected = selectedCourses.contains(course.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedCourses.remove(course.id);
                            } else {
                              selectedCourses.add(course.id);
                            }
                          });
                        },
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val!) {
                                selectedCourses.add(course.id);
                              } else {
                                selectedCourses.remove(course.id);
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        title: Text(
                          course.courseName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          course.courseCode,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.check_circle,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedCourses.isEmpty
                      ? null
                      : () => _submitSelection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'تأكيد الاختيار (${selectedCourses.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _submitSelection(BuildContext context) async {
    try {
      if (widget.role == 'student') {
        await courseService.enrollStudentInCourses(
          widget.userId,
          selectedCourses.toList(),
        );
      } else {
        await courseService.assignProfessorToCourses(
          widget.userId,
          selectedCourses.toList(),
        );
      }

      Get.snackbar(
        'نجاح',
        'تم حفظ اختيارك بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to home based on role
      if (widget.role == 'student') {
        Get.offAllNamed('/student_home');
      } else {
        Get.offAllNamed('/professor_home');
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حفظ الاختيار: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
