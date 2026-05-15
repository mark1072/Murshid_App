import 'package:musrshid_app/src/features/courses/model/course_model.dart';
import 'package:musrshid_app/src/features/schedule/model/room_model.dart';

class ScheduleModel {
  final int id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final CourseModel course;
  final RoomModel room;
  final String? professorId; // معرف المدرس

  ScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.course,
    required this.room,
    this.professorId,
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
      professorId: json['courses']?['professor_id'], // جلب معرف المدرس من courses
    );
  }
}
