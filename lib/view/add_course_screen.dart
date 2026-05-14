import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/course_creation_controller.dart';
import '../controllers/professor_controller.dart';
import '../services/room_service.dart';
import '../services/student_management_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final courseController = Get.put(CourseCreationController());
  final roomService = Get.find<RoomService>();
  final studentService = Get.find<StudentManagementService>();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseCodeController;
  late TextEditingController _courseNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  final _currentStep = 0.obs;
  int? _selectedRoomId;
  String _selectedDay = 'Monday';
  final Set<String> _selectedStudentIds = {};

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _courseCodeController = TextEditingController();
    _courseNameController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Text(
          'add_new_lecture'.tr,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep.value,
        onStepCancel: _currentStep.value > 0
            ? () => setState(() => _currentStep.value--)
            : null,
        onStepContinue: () => _onStepContinue(),
        steps: [
          // Step 1: Course Details
          Step(
            title: Text('course_details'.tr),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _courseCodeController,
                    decoration: InputDecoration(
                      labelText: 'course_code'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'enter_course_code'.tr : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _courseNameController,
                    decoration: InputDecoration(
                      labelText: 'course_name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.book),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'enter_course_name'.tr : null,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),

          // Step 2: Room and Time
          Step(
            title: Text('room_and_time'.tr),
            content: Column(
              children: [
                // Room Selection
                Obx(() {
                  if (roomService.isLoading.value) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedRoomId,
                    decoration: InputDecoration(
                      labelText: 'select_room'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: roomService.rooms
                        .map(
                          (room) => DropdownMenuItem(
                            value: room.id,
                            child: Text(
                              '${room.buildingName} - ${room.roomNumber}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedRoomId = val),
                  );
                }),
                const SizedBox(height: 16),
                // Day Selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedDay,
                  decoration: InputDecoration(
                    labelText: 'select_day'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _days
                      .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedDay = val ?? 'Monday'),
                ),
                const SizedBox(height: 16),

                // Start Time
                TextFormField(
                  controller: _startTimeController,
                  decoration: InputDecoration(
                    labelText: 'start_time'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context, _startTimeController),
                ),
                const SizedBox(height: 16),

                // End Time
                TextFormField(
                  controller: _endTimeController,
                  decoration: InputDecoration(
                    labelText: 'end_time'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(context, _endTimeController),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),

          // Step 3: Add Students
          Step(
            title: Text('add_students'.tr),
            content: Obx(() {
              if (studentService.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${'selected_students_count'.tr} ${_selectedStudentIds.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: studentService.students.length,
                      itemBuilder: (context, index) {
                        final student = studentService.students[index];
                        final isSelected = _selectedStudentIds.contains(
                          student.id,
                        );
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val!) {
                                _selectedStudentIds.add(student.id);
                              } else {
                                _selectedStudentIds.remove(student.id);
                              }
                            });
                          },
                          title: Text(student.fullName),
                          subtitle: Text(student.universityId),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _onStepContinue() async {
    if (_currentStep.value == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep.value++);
      }
    } else if (_currentStep.value == 1) {
      // make function to check if the selected room is available at the selected time and day
      final isRoomAvailable = await _checkRoomAvailability();
      if (_selectedRoomId != null &&
          _startTimeController.text.isNotEmpty &&
          _endTimeController.text.isNotEmpty &&
          isRoomAvailable) {
        setState(() => _currentStep.value++);
      } else {
        Get.snackbar('warning'.tr, 'fill_all_fields'.tr);
      }
    } else if (_currentStep.value == 2) {
      // Final step - Create course and schedule
      // if no students selected, show message you shouldd select at least one student
      if (_selectedStudentIds.isEmpty) {
        Get.snackbar(
          'warning'.tr,
          'select_at_least_one_student'.tr,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      await _createCourseAndSchedule();
    }
  }

  Future<void> _createCourseAndSchedule() async {
    try {
      // 1. Create the course
      final courseId = await courseController.createNewCourse(
        courseCode: _courseCodeController.text.trim(),
        courseName: _courseNameController.text.trim(),
      );

      if (courseId == null) {
        Get.snackbar('error'.tr, 'course_creation_failed'.tr);
        return;
      }

      // 2. Create the schedule
      final scheduleId = await courseController.createSchedule(
        courseId: courseId,
        roomId: _selectedRoomId!,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        dayOfWeek: _selectedDay,
        studentIds: _selectedStudentIds.toList(),
      );

      if (scheduleId == null) {
        Get.snackbar('error'.tr, 'schedule_creation_failed'.tr);
        return;
      }

      // 3. Students already added in createSchedule method
      Get.snackbar(
        'success'.tr,
        'course_created_success'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh professor schedules before navigating
      final professorController = Get.find<ProfessorController>();
      await professorController.fetchProfessorSchedule();

      Get.offNamed('/professor_home');
    } catch (e) {
      debugPrint('===== \nError in course creation flow: $e');
      Get.snackbar('error'.tr, '${'error_occurred'.tr} $e');
    }
  }

  Future<bool> _checkRoomAvailability() async {
    try {
      final isAvailable = await roomService.isRoomAvailable(
        roomId: _selectedRoomId!,
        dayOfWeek: _selectedDay,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
      );
      if (!isAvailable) {
        Get.snackbar(
          'unavailable'.tr,
          'room_unavailable_message'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return isAvailable;
    } catch (e) {
      debugPrint('===== \nError checking room availability: $e');
      Get.snackbar('error'.tr, '${'error_occurred'.tr} $e');
      return false;
    }
  }
}
