import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';

class RoomService extends GetxService {
  final supabase = Supabase.instance.client;

  var rooms = <RoomModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllRooms();
  }

  // Fetch all available rooms
  Future<void> fetchAllRooms() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('rooms')
          .select('*')
          .order('room_number');

      rooms.value = response.map((item) => RoomModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
