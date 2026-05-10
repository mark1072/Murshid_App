import 'course_model.dart';
import 'room_model.dart';

class ScheduleModel {
  final int id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final CourseModel course;
  final RoomModel room;

  ScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.course,
    required this.room,
  });

  // تحويل البيانات القادمة من Supabase (Map) إلى كائن (Object)
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      course: CourseModel.fromJson(json['courses']), // علاقة Nested
      room: RoomModel.fromJson(json['rooms']), // علاقة Nested
    );
  }
}
