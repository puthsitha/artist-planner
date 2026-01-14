import 'package:url_launcher/url_launcher.dart';

abstract class DeeplinkHelper {
  // static Future<void> launchDeepLink(String url) async {
  //   if (!await launchUrlString(url)) throw 'Could not launch $url';
  // }

  static Future<void> openUrl(String link) async {
    final url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch the link.');
    }
  }

  static Future<void> launchGoogleMap({
    required double lat,
    required double lng,
  }) async {
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open the map.');
    }
  }

  static Future<void> makePhoneCall({required String mobile}) async {
    final phoneUri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw Exception('Could not make phone call to $mobile.');
    }
  }
}
