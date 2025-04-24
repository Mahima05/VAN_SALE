import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchBillAPI {
  static Future<List<Map<String, dynamic>>> fetchSalesData(
      String branchId, String fromDate,String channel, String token) async {
    final url =
        'https://retailuat.abisibg.com/api/v1/fetchsale?branchId=$branchId&TransTypeId=SALE&ChannelID=$channel&businessDate=$fromDate';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to fetch sales data');
    }
  }
}
