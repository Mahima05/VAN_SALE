import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerNameAPI {
  static Future<List<Map<String, dynamic>>> fetchCustomersByName(
      String customerType, String customerName, String bearerToken) async {
    final url = Uri.parse(
        'https://retailuat.abisaio.com:9001/api/POSCustomerSerch/Get/$customerType/CUSTNAME/$customerName');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['customers'] != null) {
          return List<Map<String, dynamic>>.from(
              data['customers'].map((customer) => {
                    'custID': customer['custID'],
                    'customerName': customer['customerName'],
                    'mobile': customer['mobile'],
                'email' : customer['email'],
                "creditLimit": customer['creditLimit'],
                "creditDays": customer['creditDays'],
                'branchID' : customer['branchID'],
                  }));
        }
      }
      throw Exception('Failed to load customers');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
