import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeSlotAPI {
  static const String baseUrl = 'https://retailuat.abisibg.com/api/v1/timeslot';
  static const String branchId = 'L111'; // Replace with dynamic branchId if needed

  static Future<List<Map<String, String>>> fetchTimeSlots(String bearerToken) async {
    final url = Uri.parse('$baseUrl?branchId=$branchId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        'TimeSlotId': item['TimeSlotId'] as String,
        'TimeSlotName': item['TimeSlotName'] as String,
      }).toList();
    } else {
      throw Exception('Failed to fetch time slots: ${response.statusCode}');
    }
  }
}
