import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentGatewayAPI {
  static Future<List<Map<String, dynamic>>> fetchPaymentGateways(String paymentMethodId, String bearerToken) async {
    final url = Uri.parse('https://retailuat.abisibg.com/api/v1/paymentgateway?MethodID=$paymentMethodId');

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
        // Filter out deleted gateways and sort by DisplaySeq if needed
        final sortedData = data
            .where((item) => item['Deleted'] == 'N')
            .toList()
          ..sort((a, b) => (a['DisplaySeq'] as int).compareTo(b['DisplaySeq'] as int));

        return sortedData.map<Map<String, dynamic>>((item) => {
          'PaymentGatewayId': item['PaymentGatewayId'] as String? ?? '',
          'PaymentGatewayName': item['PaymentGatewayName'] as String? ?? '',
          'PaymentMethodId': item['PaymentMethodId'] as String? ?? '',
          'DisplaySeq': item['DisplaySeq'] as int? ?? 0,
          'ExpenseOnly': item['ExpenseOnly'] as bool? ?? false,
          'IsVehiclePay': item['IsVehiclePay'] as bool? ?? false,
          'IsPOSReceipt': item['IsPOSReceipt'] as bool? ?? false,
          'IsGeneralReceipt': item['IsGeneralReceipt'] as bool? ?? false,
          'isPOSRefund': item['isPOSRefund'] as bool? ?? false,
        }).toList();
      } else {
        throw Exception('Failed to load payment gateways: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment gateways: $e');
      throw Exception('Error fetching payment gateways');
    }
  }
}
