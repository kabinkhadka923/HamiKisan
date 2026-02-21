import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneCallService {
  /// Make a phone call to the specified phone number
  static Future<bool> makeCall(String phoneNumber) async {
    try {
      // Request CALL_PHONE permission
      final status = await Permission.phone.request();

      if (status.isDenied) {
        return false;
      }

      if (status.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }

      // Make the call
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if device can make calls
  static Future<bool> canMakeCall() async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: '1234567890',
      );
      return await canLaunchUrl(launchUri);
    } catch (e) {
      return false;
    }
  }
}
