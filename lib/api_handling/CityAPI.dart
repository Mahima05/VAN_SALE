import 'dart:convert';
import 'package:http/http.dart' as http;

class CityAPI {
  static Future<List<Map<String, String>>> fetchCities(
      String token, String stateCode) async {
    final String url =
        'https://retailuat.abisibg.com/api/v1/city?StateCode=$stateCode';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((dynamic city) {
          return {
            'CityName': city['CityName'] as String,
            'CityCode': city['CityCode'] as String,
          };
        }).toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }
}
