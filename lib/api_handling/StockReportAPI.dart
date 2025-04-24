import 'dart:convert';
import 'package:abis2/login_handling/login.dart';
import 'package:http/http.dart' as http;

class StockReportAPI {
  static const String _baseUrl =
      "https://retailuat.abisibg.com/api/v1/fetchstock";
  static  String _bearerToken = loginBearerToken;

  static Future<List<Map<String, dynamic>>> fetchStock(String branchID, String binID) async {
    final Uri url = Uri.parse(
        "$_baseUrl?BranchID=$branchID&BinId=$binID&ItemStatusID=ALL&ItemCategoryId=ALL&Channel=VAN&ItemID=ALL&BatchNumber=ALL");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $_bearerToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      return data
          .where((item) => (item["StockQty"] > 0 /*&& item["StockAltQty"] >= 0*/))
          .map((item) => {
        "ItemID": item["ItemID"],
        "ItemName": item["ItemName"],
        "CategoryName": item["CategoryName"],
        "BatchNumber": item["BatchNumber"] ?? "",
        "StockQty": item["StockQty"],
        "StockAltQty": item["StockAltQty"],
        "BinName": binID,
      })
          .toList();
    } else {
      throw Exception("Failed to load stock data");
    }
  }
}
