import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessChannelAPI {
  static Future<List<String>> fetchBusinessChannelCodes(String bearerToken,String branchID) async {
     final url =
        'https://retailuat.abisibg.com/api/v1/businesschannels?BranchId=$branchID';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<String>((channel) => channel['BusinessChannelCode'] as String)
          .toList();
    } else {
      throw Exception("Failed to fetch business channels: ${response.body}");
    }
  }
}
