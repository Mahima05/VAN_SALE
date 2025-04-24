import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchBillDetailsAPI {
  static Future<Map<String, dynamic>?> fetchBillDetails(String branchID, String saleID, String token) async {
    final url = Uri.parse("https://retailuat.abisibg.com/api/v1/fetchsale2?BranchID=$branchID&SaleID=$saleID");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
