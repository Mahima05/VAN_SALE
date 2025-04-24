import 'dart:convert';
import 'package:http/http.dart' as http;



class ItemCategoryAPI {

  static Future<List<Map<String, dynamic>>> fetchItemCategory(String branchId, String bearerToken) async {
    final url = Uri.parse('https://retailuat.abisibg.com//api/v1/itemcategorylist?branchId=$branchId');

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
        return data
            .map<Map<String, dynamic>>((item) => {
          'CategoryName': item['CategoryName'].toString(),
          'ItemCategoryID': item['ItemCategoryID'].toString(),
          'ItemFamilyID': item['ItemFamilyID'].toString(),
        })
            .toList();
      } else {
        throw Exception('Failed to load item names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item names: $e');
      throw Exception('Error fetching item names');
    }
  }
}
