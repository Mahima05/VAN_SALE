import 'dart:convert';
import 'package:http/http.dart' as http;

class StateNameAPI {
  static Future<List<Map<String, String>>> fetchStates(String token) async {
    const String url = 'https://retailuat.abisibg.com/api/v1/state';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((dynamic state) {
          return {
            'StateName': state['StateName'] as String,
            'StateCode': state['StateCode'] as String,
          };
        }).toList();
      } else {
        throw Exception('Failed to load states');
      }
    } catch (e) {
      throw Exception('Error fetching states: $e');
    }
  }
}

