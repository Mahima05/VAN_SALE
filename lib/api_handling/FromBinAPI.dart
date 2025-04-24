import 'dart:convert';
import 'package:http/http.dart' as http;

class FromBinAPI {
  static Future<List<Map<String, dynamic>>> fetchBins(String branchId, String bearerToken) async {
    String url = 'https://retailuat.abisibg.com/api/v1/FetchBin?BranchID=$branchId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((bin) => {
          'BinID': bin['BInID'],
          'BinName': bin['BinName'],
        }).toList();
      } else {
        throw Exception('Failed to load bins: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching bins: $e');
      return [];
    }
  }
}
