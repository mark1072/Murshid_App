class NotificationModel {
  final int id;
  final String senderId;
  final String title;
  final String message;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      senderId: json['sender_id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
