import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationAreaAPI {
  static const String apiUrl = 'https://retailuat.abisaio.com:9001/api/SFArea/';

  static Future<List<String>> fetchAreaNames(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl$userId'), // Append userId to the URL
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Request URL: ${'$apiUrl$userId'}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((area) => area['sfAreaName'] as String).toList();
      } else {
        throw Exception('Failed to load location areas');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

}
