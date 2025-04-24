import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemNameAPI {
  static Future<List<Map<String, dynamic>>> fetchItemNames(
      String branchId, String itemCategoryId, String bearerToken) async {
    final url = Uri.parse(
        'https://retailuat.abisibg.com//api/v1/itemlistbycategory?branchId=$branchId&itemCategoryId=$itemCategoryId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        return data.map<Map<String, dynamic>>((item) => {
          "itemID": item['ItemID'].toString(),
          "Partnumber": item['Partnumber'].toString(),
          "ItemName": item['ItemName'].toString(),
        }).toList();
      } else {
        throw Exception('Failed to load item types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item types: $e');
      throw Exception('Error fetching item types');
    }
  }
}

