import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryApi {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil kategori');
    }
  }
}