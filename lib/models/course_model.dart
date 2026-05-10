class CourseModel {
  final int id;
  final String courseCode;
  final String courseName;

  CourseModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      courseCode: json['course_code'],
      courseName: json['course_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'course_code': courseCode,
    'course_name': courseName,
  };
}
