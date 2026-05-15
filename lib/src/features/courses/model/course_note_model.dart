class CourseNoteModel {
  final int? id;
  final String studentId;
  final String professorId;
  final int courseId;
  final String courseCode;
  final String courseName;
  final String noteText;
  final DateTime createdAt;
  final bool isRead;
  final String? studentName;
  final String? professorName;

  CourseNoteModel({
    this.id,
    required this.studentId,
    required this.professorId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.noteText,
    required this.createdAt,
    this.isRead = false,
    this.studentName,
    this.professorName,
  });

  factory CourseNoteModel.fromJson(Map<String, dynamic> json) {
    return CourseNoteModel(
      id: json['id'],
      studentId: json['student_id'],
      professorId: json['professor_id'],
      courseId: json['course_id'],
      courseCode: json['course_code'],
      courseName: json['course_name'],
      noteText: json['note_text'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      studentName: json['student_name'],
      professorName: json['professor_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'professor_id': professorId,
    'course_id': courseId,
    'course_code': courseCode,
    'course_name': courseName,
    'note_text': noteText,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
  };
}
