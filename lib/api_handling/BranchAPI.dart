import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abis2/login_handling/login.dart';

class BranchAPI {
  static Future<List<Branch>> fetchBranches(String userId, String authToken) async {
    // Ensure userId is 10 digits by adding leading zeroes if necessary
    if (userId.length < 10) {
      userId = userId.padLeft(10, '0');
    }

    final response = await http.get(
      Uri.parse('https://retailuat.abisibg.com/api/v1/branchaccess?EmpId=$userId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((branch) => Branch.fromJson(branch)).toList();
    } else {
      throw Exception('Failed to load branches');
    }
  }
}




