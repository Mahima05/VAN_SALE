import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemAltQtyWeightAPI {
  static Future<Map<String, dynamic>?> fetchItemFamilyDetails(
      String branchId, String bearerToken, String selectedItemFamilyId) async {
    final url = Uri.parse(
        'https://retailuat.abisibg.com/api/v1/itemfamilylist?branchId=$branchId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Find the item family by selectedItemFamilyId
        final itemFamily = data.firstWhere(
              (item) => item['ItemFamilyID'] == selectedItemFamilyId,
          orElse: () => {},
        );

        if (itemFamily.isNotEmpty) {
          return {
            'AltQtyEnabled': itemFamily['AltQtyEnabled'] ?? false,
            'SellByWeight': itemFamily['SellByWeight'] ?? false,
          };
        } else {
          print("ItemFamilyID $selectedItemFamilyId not found.");
          return null;
        }
      } else {
        throw Exception(
            'Failed to load item family details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item family details: $e');
      return null;
    }
  }
}
