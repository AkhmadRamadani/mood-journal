import 'dart:convert';

import 'package:moodie/models/quore_response.dart';
import 'package:http/http.dart' as http;

class DashboardRepository {
  Future<QuoteResponse?> getQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=happiness'),
      );
      if (response.statusCode == 200) {
        return QuoteResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      return null;
    }
  }
}
