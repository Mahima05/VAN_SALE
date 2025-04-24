import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerAddAPI {
  final String apiUrl = "https://retailUAT.abisaio.com:9001/api/POSCustomer";

  static String getCurrentDateTime() {
    DateTime now = DateTime.now().toUtc();
    return now.toIso8601String();
  }



  // Function to add customer details
  Future<Map<String, dynamic>> addCustomerDetails({
    required String token,
    required String customerCode,
    required String? title,
    required String customerName,
    required String mobile,
    required String email,
    required String houseNo,
    required String building,
    required String customerAddress,
    required String landmark,
    required String pinCode,
    required String? cityCode,
    required String? areaName,
    required String? areaId,
  }) async {
    String currentTimestamp = getCurrentDateTime();
    try {
      // Request headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

       final body =  {

         "custID": "",

         "customerCode": "",

         "title": "",

         "customerName": customerName,

         "mobile": mobile,

         "email": email,

         "branchID": "L101",

         "addressID": "",

         "isDafault": true,

         "isLastDelvAddress": true,

         "houseNo": houseNo,

         "building": building,

         "customerAddress": customerAddress,

         "landmark": landmark,

         "cityCode": cityCode,

         "placeCode": areaId,

         "isDistanceEdited": true,

         "kmDistance": 0,

         "placeName": areaName,

         "pinCode": pinCode,

         "altPhone": "",

         "createdUserId": "",

         "createdDate": currentTimestamp,

         "modifiedUserId": "",

         "modifiedDate": currentTimestamp,

         "deletedUserId": "",

         "deletedDate": currentTimestamp,

       };

      print('Request Body: ${json.encode(body)}');


      // Sending POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),

      );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "result": 0,
          "description": "Error: ${response.statusCode} ${response.reasonPhrase}"
        };
      }
    } catch (e) {
      return {
        "result": 0,
        "description": "Exception: $e"
      };
    }
  }
}
