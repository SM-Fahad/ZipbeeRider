import 'package:url_launcher/url_launcher.dart';

class ExternalLauncherService {
  static Future<void> openDialer(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:${phoneNumber.trim()}");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> openSms(String phoneNumber) async {
    final Uri uri = Uri.parse("sms:${phoneNumber.trim()}");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}