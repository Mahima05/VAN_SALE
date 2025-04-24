import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemDetailsAPI {
  static Future<Map<String, dynamic>?> fetchItemDetails(
      String itemId, String bearerToken) async {
    final url = Uri.parse(
        'https://retailuat.abisibg.com/api/v1/itemdetail?PartNumber=$itemId');

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
          final item = data.first;
          return {
            "ItemID": item['ItemID'].toString(),
            "Partnumber": item['Partnumber'].toString(),
            "ItemName": item['ItemName'].toString(),
            "LongDescription": item['LongDescription'].toString(),
            "ItemCategoryID": item['ItemCategoryID'].toString(),
            "ItemFamilyID": item['ItemFamilyID'].toString(),
            "StockGroupID": item['StockGroupId'].toString(),
            "TaxCategoryID": item['TaxCategoryId'].toString(),
            "BrandID": item['BrandID'].toString(),
            "ShelfLifeDays": item['ShelfLifeDays'].toString(),
            "UnitMinWt": item['UnitMinWt'].toDouble(),
            "UnitMaxWt": item['UnitMaxWt'].toDouble(),
            "SellByWeight": item['SellByWeight'] ?? false,
            "AltQtyEnabled": item['AltQtyEnabled'] ?? false,
            "AmountModeAllowed": item['AmountModeAllowed'] ?? false,
            "TotalTaxPercent": item['TotalTaxPercent'].toDouble(),
            "UOMID": item['UOMID'].toString(),
            "StockGroupName": item['StockGroupName'].toString(),
            "BatchEnabled": item['BatchEnabled'] ?? false,
          };
        } else {
          return null;
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
