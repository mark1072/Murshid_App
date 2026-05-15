import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

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
    final wasConnected = isConnected.value;
    isConnected.value = result != ConnectivityResult.none;

    if (wasConnected && !isConnected.value) {
      _showOfflineSnackbar();
    } else if (!wasConnected && isConnected.value) {
      _showOnlineSnackbar();
      _triggerSync();
    }
  }

  void _showOfflineSnackbar() {
    Get.rawSnackbar(
      title: "لا يوجد اتصال بالإنترنت",
      message: "يتم العرض من البيانات المحفوظة",
      backgroundColor: Colors.redAccent,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showOnlineSnackbar() {
    Get.rawSnackbar(
      title: "تم استعادة الاتصال",
      message: "جاري تحديث البيانات...",
      backgroundColor: Colors.green,
      icon: const Icon(Icons.wifi, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _triggerSync() {
    // استدعاء دوال المزامنة في المتحكمات المختلفة
    try {
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().performPostLoginSync();
      }
    } catch (e) {
      debugPrint("Error triggering sync: $e");
    }
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
