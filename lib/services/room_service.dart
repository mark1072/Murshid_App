import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'connectivity_service.dart';

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
      final connectivity = Get.find<ConnectivityService>();
      final box = await Hive.openBox('roomsBox');

      if (connectivity.isConnected.value) {
        final response = await supabase
            .from('rooms')
            .select('*')
            .order('room_number');
        rooms.value = response.map((item) => RoomModel.fromJson(item)).toList();
        await box.put('all', response);
      } else {
        final cached = box.get('all');
        if (cached != null) {
          rooms.value = (cached as List)
              .map(
                (item) => RoomModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        } else {
          rooms.value = [];
        }
      }
    } catch (e) {
      debugPrint('Error fetching rooms: $e');
      rooms.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}
