import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchVehicleAPI {
  static Future<List<Map<String, dynamic>>> fetchVehicles(String branchId, String bearerToken) async {
    final url = Uri.parse("https://retailuat.abisibg.com/api/v1/fetchvehicle?BranchID=$branchId&companyCode=ALL");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
