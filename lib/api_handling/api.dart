import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://retailUAT.abisaio.com:9001/api/Login/Post';

  static Future<Map<String, dynamic>> loginUser(String userId, String password) async {
    final Map<String, String> body = {
      'email': 'email',
      'password': password,
      'userId': userId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Request Body: ${jsonEncode(body)}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['token'] != null && responseData['token'].toString().isNotEmpty) {
          return {
            'success': true,
            'token': responseData['token'],
            'user': responseData['user'],
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response: Missing token.',
          };
        }
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['title'] ?? 'Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Exception occurred: $e',
      };
    }

    // Fallback return (to satisfy Dart's null-safety)
    return {
      'success': false,
      'message': 'Unknown error occurred.',
    };
  }
}
