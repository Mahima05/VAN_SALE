import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemWeightAPI {
  static Future<Map<String, double>?> fetchItemWeight(
      String branchId, String itemId, String bearerToken) async {
    final String url = 'https://retailuat.abisibg.com/api/v1/itemlist?branchId=$branchId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> items = json.decode(response.body);

        for (var item in items) {
          if (item['ItemID'] == itemId) {
            double minWeight = (item['UnitMinWt'] as num).toDouble();
            double maxWeight = (item['UnitMaxWt'] as num).toDouble();

            return {
              'minWeight': minWeight,
              'maxWeight': maxWeight,
            };
          }
        }
      } else {
        print('Failed to fetch item weights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item weights: $e');
    }

    return null;
  }
}
