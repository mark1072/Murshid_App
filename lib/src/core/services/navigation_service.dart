// flutter pub add geocoding url_launcher geolocator
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class NavigationService extends GetxService {
  // دالة لفتح الخريطة الخارجية وتوجيه المستخدم للقاعة
  Future<void> openMapToDestination(double lat, double lng) async {
    // 1. رابط الخريطة (يعمل على أندرويد و آيفون)
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final String appleMapsUrl = "https://maps.apple.com/?q=$lat,$lng";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
      await launchUrl(
        Uri.parse(appleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
      Get.snackbar("خطأ", "لا يمكن فتح تطبيق الخرائط");
    }
  }

  //

  // دالة اختيارية للحصول على المسافة بين الطالب والقاعة
  Future<double> getDistanceToRoom(double destLat, double destLng) async {
    // التأكد من صلاحيات الموقع أولاً
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    // حساب المسافة بالمتر
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      destLat,
      destLng,
    );

    return distanceInMeters;
  }
}
