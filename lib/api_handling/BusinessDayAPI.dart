import 'dart:convert';
import 'package:http/http.dart' as http;

class BusinessDayAPI {
  static Future<String?> fetchBusinessDate(String bearerToken, String branchId) async {
    final String apiUrl = "https://retailuat.abisibg.com/api/v1/currentbusinessday?BranchId=$branchId";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['BusinessDateCode'] != null) {
          // Extract only the date portion before 'T'
          String businessDateCode = data[0]['BusinessDateCode'].split('T')[0];

          // Split into [YYYY, MM, DD]
          List<String> parts = businessDateCode.split('-');

          // Rearrange to DD-MM-YYYY
          return "${parts[2]}-${parts[1]}-${parts[0]}";
        }
      }
    } catch (e) {
      print("Error fetching business date: $e");
    }
    return null;
  }
}
