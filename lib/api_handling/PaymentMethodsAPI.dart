import 'dart:convert';
import 'package:http/http.dart' as http;



class Paymentmethodsapi {

  static Future<List<Map<String, dynamic>>> fetchPaymentsMethods(String branchId, String bearerToken) async {
    final url = Uri.parse('https://retailuat.abisibg.com/api/v1/branchpayment?BranchID=$branchId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        return data
            .map<Map<String, dynamic>>((item) => {
          'PaymentGatewayId': item['PaymentGatewayId'] as String,
          'PaymentGatewayName': item['PaymentGatewayName'] as String,
          'PaymentMethodId': item['PaymentMethodId'] as String,
        })
            .toList();
      } else {
        throw Exception('Failed to load payment methods: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      throw Exception('Error fetching payment methods');
    }
  }
}
