import 'dart:convert';
import 'package:http/http.dart' as http;

class DayRateReportAPI {
  static const String _baseUrl =
      "https://retailuat.abisibg.com/api/v1/fetchstock";

  static Future<List<Map<String, dynamic>>> fetchDayRateReportByChannel(
      String branchID, String binID,String channel,  String bearerToken) async {
    final Uri url = Uri.parse(
        "$_baseUrl?BranchID=$branchID&BinId=$binID&ItemStatusID=ALL&ItemCategoryId=ALL&Channel=$channel&ItemID=ALL&BatchNumber=ALL");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $bearerToken",
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {
        "ItemID": item["ItemID"],
        "ItemName": item["ItemName"],
        "CategoryName": item["CategoryName"],
        "Rate": item["rate"] ?? "0",
        "Channel": channel,
      }).toList();
    } else {
      throw Exception("Failed to load stock data for channel $channel");
    }
  }
}