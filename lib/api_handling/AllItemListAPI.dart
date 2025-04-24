import 'dart:convert';
import 'package:http/http.dart' as http;

class AllItemListAPI {



  static Future<List<Map<String, dynamic>>> fetchItems(String bearerToken, String branchID) async {
    final apiUrl = 'https://retailuat.abisibg.com//api/v1/itemlist?branchId=$branchID';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          return {
            "ItemID": item["ItemID"],
            "ItemName": item["ItemName"],
            "ItemCategoryID": item["ItemCategoryID"],
            "ItemFamilyID": item["ItemFamilyID"],
          };
        }).toList();
      } else {
        throw Exception("Failed to load items");
      }
    } catch (e) {
      print("Error fetching items: $e");
      return [];
    }
  }
}
