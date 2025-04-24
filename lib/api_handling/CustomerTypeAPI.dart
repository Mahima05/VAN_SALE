import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerTypeAPI {
  static Future<List<String>> fetchCustomerTypes(String token, String branchId) async {
    final url = Uri.parse(
        'https://retailuat.abisibg.com/api/v1/customertype?BranchId=$branchId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        // Extract the CustomerTypeCode from the API response
        return responseData
            .map<String>((type) => type['CustomerTypeCode'] as String)
            .toList();
      } else {
        throw Exception('Failed to load customer types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching customer types: $e');
    }
  }
}
