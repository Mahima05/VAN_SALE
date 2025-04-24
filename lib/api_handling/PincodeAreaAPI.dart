import 'dart:convert';
import 'package:http/http.dart' as http;

class PincodeAreaAPI {
  static const String baseUrl = "https://retailuat.abisaio.com:9001/api/Place/";

  static Future<List<Map<String, String>>> fetchAreas(String pincode, String bearerToken) async {
    final url = "$baseUrl$pincode";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['places'] != null) {
          return List<Map<String, String>>.from(
            data['places'].map((place) => {
              'placeId': place['placeId'].toString(),
              'placeName': place['placeName'].toString(),
            }),
          );
        }
      }
      return [];
    } catch (e) {
      print("Error fetching areas: $e");
      return [];
    }
  }
}
