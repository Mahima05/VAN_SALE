import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchCustomerAddressAPI {
  static Future<List<Map<String, dynamic>>?> fetchCustomerDetails(
      String bearerToken, String branchId, String customerId) async {
    String apiUrl =
        "https://retailuat.abisibg.com/api/v1/fetchaddress?BranchID=$branchId&CustId=";

    final Uri url = Uri.parse("$apiUrl$customerId");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          return data.map((item) => {
            "CustID": item['CustID'] ?? "",
            "AddressID": item['AddressID'] ?? "",
            "CustomerAddress": item['CustomerAddress'] ?? "",
            "HouseNo": item['HouseNo'] ?? "",
            "AltPhone": item['AltPhone'] ?? "",
            "Building": item['Building'] ?? "",
            "PINCODE": item['PINCODE'] ?? "",
            "PlaceID": item['PlaceID'] ?? "",
            "CityID": item['CityID'] ?? "",
            "KmDistance": item['kmdistance'] != null
                ? double.tryParse(item['kmdistance'].toString())
                : null,
            "Landmark": item['Landmark'] ?? "",
            "PlaceName": item['PlaceName'] ?? "",
            "CityName": item['CityName'] ?? "",
            "StateName": item['StateName'] ?? "",
          }).toList();
        }
      }
    } catch (e) {
      print("Error fetching customer details: $e");
    }
    return null;
  }
}
