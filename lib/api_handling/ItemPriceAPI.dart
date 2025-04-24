import 'package:http/http.dart' as http;

class ItemPriceAPI {
  static Future<Map<String, dynamic>?> fetchItemPrice(
      String businessDate, String branchId, String? channelType, String itemId, String bearerToken) async {
    final String url =
        'https://retailuat.abisaio.com:9001/api/ChannelRate/$branchId/$businessDate/$channelType/$itemId/ALL';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        double? rate = double.tryParse(response.body.trim());

        if (rate != null) {
          return {'rate': rate};
        } else {
          print('Invalid response format: ${response.body}');
        }
      } else {
        print('Failed to fetch item rate: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching item rate: $e');
    }

    return null;
  }
}
