import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/api_endpoints.dart';

class PhishingRepository {
  // POST to Google Safe Browsing API
  Future<List<String>> checkUrls(List<String> urls) async {
    if (urls.isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse(
          '${ApiEndpoints.safeBrowsingUrl}?key=${ApiEndpoints.safeBrowsingKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client': {'clientId': 'bongkar', 'clientVersion': '1.0'},
          'threatInfo': {
            'threatTypes': ['MALWARE', 'SOCIAL_ENGINEERING'],
            'platformTypes': ['ANY_PLATFORM'],
            'threatEntryTypes': ['URL'],
            'threatEntries': urls.map((u) => {'url': u}).toList(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['matches'] != null) {
          return (data['matches'] as List)
              .map((m) => m['threat']['url'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      // No internet or API error — app won't crash
      return [];
    }
  }
}
