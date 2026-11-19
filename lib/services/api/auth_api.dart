import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth_session.dart';
import 'quiz_api.dart';

class AuthApi {
  AuthApi._();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${QuizApi.baseUrl}/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Gagal login');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${QuizApi.baseUrl}/register'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Gagal register');
  }

  static Future<void> logout() async {
    final token = AuthSession.token;

    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('${QuizApi.baseUrl}/logout'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal logout dari server');
    }
  }
}
