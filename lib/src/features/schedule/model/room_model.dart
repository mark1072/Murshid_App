class RoomModel {
  final int id;
  final String buildingName;
  final String floorNumber;
  final String roomNumber;
  final double? latitude;
  final double? longitude;

  RoomModel({
    required this.id,
    required this.buildingName,
    required this.floorNumber,
    required this.roomNumber,
    this.latitude,
    this.longitude,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      buildingName: json['building_name'],
      floorNumber: json['floor_number'],
      roomNumber: json['room_number'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  // دالة مساعدة لعرض الاسم الكامل للقاعة في الواجهة
  String get fullLocation => '$buildingName - $floorNumber - $roomNumber';
}
