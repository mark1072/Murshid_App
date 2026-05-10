import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  late Connectivity _connectivity;
  final isConnected = true.obs;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _initConnectivity();
    _listenConnectivity();
  }

  // فحص الحالة الأولية للاتصال
  void _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint("===== \nError checking connectivity: $e");
      isConnected.value = false;
    }
  }

  // الاستماع لتغييرات الاتصال
  void _listenConnectivity() {
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  // تحديث حالة الاتصال
  void _updateConnectionStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;
  }

  // دالة للتحقق من الاتصال الحالي
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint("Error checking connection: $e");
      return false;
    }
  }
}
