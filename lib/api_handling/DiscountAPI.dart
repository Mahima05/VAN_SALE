import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscountAPI {
  static Future<List<Map<String, dynamic>>> fetchDiscounts(String branchId, String bearerToken) async {
    final url = Uri.parse('https://retailuat.abisibg.com/api/v1/discount?BranchId=$branchId');

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
            .map<Map<String, dynamic>>((discount) => {
          'DiscountCode': discount['DiscountCode'].toString(),
          'DiscountName': discount['DiscountName'].toString(),
        })
            .toList();
      } else {
        throw Exception('Failed to load discounts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching discounts: $e');
      throw Exception('Error fetching discounts');
    }
  }
}
