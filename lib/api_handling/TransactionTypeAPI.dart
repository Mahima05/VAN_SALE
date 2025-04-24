import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionTypeAPI {

  static Future<List<Map<String, String>>> fetchTransactionTypes(String bearerToken, String branchID) async {
      final _baseUrl =
      'https://retailuat.abisibg.com/api/v1/transcationtype?transactionTypeId=SALE&branchId=$branchID';
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        // Filter out deleted transaction types and sort by DisplaySeq
        final sortedData = data
            .where((item) => item['Deleted'] == 'N')
            .toList()
          ..sort((a, b) =>
              (a['DisplaySeq'] as int).compareTo(b['DisplaySeq'] as int));

        // Extract TranSubTypeId and TransactionTypeId in sorted order
        return sortedData
            .map<Map<String, String>>((item) => {
          'TranSubTypeId': item['TranSubTypeId'] as String,
          'TransactionTypeId': item['TransactionTypeId'] as String,
        })
            .toList();
      } else {
        throw Exception(
            'Failed to load transaction types. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch transaction types: $error');
    }
  }
}
