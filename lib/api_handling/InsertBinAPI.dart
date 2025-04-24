import 'dart:convert';
import 'package:http/http.dart' as http;

class InsertBinAPI {
  static Future<String> insertBinTransfer({
    required String branchID,
    required String binTransferDate,
    required String remarks,
    required String fromBinID,
    required String toBinID,
    required String createdUserId,
    required String transType,
    required List<Map<String, dynamic>> details,
    required String bearerToken,
  }) async {
    const String url = "https://retailuat.abisaio.com:9001/api/BinTransfer";

    Map<String, dynamic> requestBody = {
      "Option": "1",
      "BranchID": branchID,
      "BinTransferID": "",
      "TransTypeID": transType,
      "BinTransferDate": binTransferDate,
      "Remarks": remarks,
      "ISO_Number": "",
      "FromBinID": fromBinID,
      "ToBinID": toBinID,
      "Posted": false,
      "Closed": false,
      "Deleted": "N",
      "CreatedUserId": createdUserId,
      "binTransferDetail": details,
    };

    String jsonBody = jsonEncode(requestBody);
    print("JSON Body being sent: $jsonBody");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $bearerToken",
        },
        body: jsonBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData["result"] == 1) {
          String transferId = responseData["description"] ?? "Unknown";
          return "Bin Transfer Successful\nTransfer ID: $transferId";
        } else {
          return "Bin Transfer Failed\nMessage: ${responseData["description"] ?? "No description"}";
        }
      } else {
        return "Failed: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
