import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemStockAPI {
  static Future<List<Map<String, dynamic>>?> fetchItemStock(
      String binID, String branchId, String channel, String itemCategoryID, String itemID, String bearerToken) async {
    final url = Uri.parse(
        'https://retailuat.abisibg.com/api/v1/fetchstock?BranchID=$branchId&BinId=$binID&ItemStatusID=ALL&ItemCategoryId=$itemCategoryID&Channel=$channel&ItemID=$itemID&BatchNumber=ALL');

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
        if (data.isNotEmpty) {
          return data
              .where((item) =>
          (item['StockQty'] ?? 0) > 0 /*&&
              (item['StockAltQty'] ?? 0) >= 0*/)
              .map((item) => {
            "BatchNumber": item['BatchNumber'],
            "ItemID": item['ItemID'],
            "Partnumber": item['Partnumber'],
            "ItemName": item['ItemName'],
            "StockQty": item['StockQty']?.toDouble() ?? 0.0,
            "StockAltQty": item['StockAltQty'] ?? 0,
            "MRP": item['MRP']?.toDouble() ?? 0.0,
            "ItemCategoryID": item['ItemCategoryID'],
            "CategoryName": item['CategoryName'],
          })
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load item details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item details: $e');
      return null;
    }
  }
}
