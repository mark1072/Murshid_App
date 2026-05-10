class UserModel {
  final String id;
  final String universityId;
  final String fullName;
  final String role; // 'student' or 'professor'

  UserModel({
    required this.id,
    required this.universityId,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      universityId: json['university_id'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'university_id': universityId,
    'full_name': fullName,
    'role': role,
  };
}
