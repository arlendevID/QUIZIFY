import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth_session.dart';

class QuizApi {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Map<String, String> _headers({bool requiresAuth = false}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth && AuthSession.token != null) {
      headers['Authorization'] = 'Bearer ${AuthSession.token}';
    }

    return headers;
  }

  static Exception _adminException(http.Response response, String fallback) {
    if (response.statusCode == 401) {
      return Exception('Sesi login tidak valid. Silakan login ulang.');
    }

    if (response.statusCode == 403) {
      return Exception(
        'Akses ditolak. Hanya admin yang boleh melakukan aksi ini.',
      );
    }

    try {
      final data = jsonDecode(response.body);
      return Exception(data['message'] ?? fallback);
    } catch (_) {
      return Exception(fallback);
    }
  }

  static Future<List<dynamic>> getQuizzes() async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil quiz');
    }
  }

  static Future<List<dynamic>> getQuizTemplatesByCategory(
    int categoryId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quiz-templates?category_id=$categoryId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil quiz template');
    }
  }

  static Future<List<dynamic>> getQuizTemplates() async {
    final response = await http.get(Uri.parse('$baseUrl/quiz-templates'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil quiz template');
    }
  }

  static Future<Map<String, dynamic>> getUserDashboard() async {
    debugPrint(
      'GET /api/user-dashboard token exists: ${AuthSession.isAuthenticated}',
    );

    final response = await http.get(
      Uri.parse('$baseUrl/user-dashboard'),
      headers: _headers(requiresAuth: true),
    );

    debugPrint('GET /api/user-dashboard status: ${response.statusCode}');
    debugPrint('GET /api/user-dashboard response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic>) {
          return Map<String, dynamic>.from(nestedData);
        }

        return Map<String, dynamic>.from(data);
      }

      throw Exception('Format data dashboard tidak valid');
    }

    throw Exception('Gagal mengambil data dashboard');
  }

  static Future<List<dynamic>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }

      throw Exception('Format data leaderboard tidak valid');
    }

    throw Exception('Gagal mengambil data leaderboard');
  }

  static Future<Map<String, dynamic>> createQuizTemplate(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz-templates'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw _adminException(response, 'Gagal menambahkan quiz template');
    }
  }

  static Future<Map<String, dynamic>> updateQuizTemplate(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/quiz-templates/$id'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw _adminException(response, 'Gagal mengubah quiz template');
    }
  }

  static Future<void> deleteQuizTemplate(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/quiz-templates/$id'),
      headers: _headers(requiresAuth: true),
    );

    if (response.statusCode != 200) {
      throw _adminException(response, 'Gagal menghapus quiz template');
    }
  }

  static Future<List<dynamic>> getQuestionsByTemplate(int templateId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/template-questions/$templateId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal mengambil soal quiz');
    }
  }

  static Future<Map<String, dynamic>> createTemplateQuestion(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/template-questions'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw _adminException(response, 'Gagal menambahkan soal');
    }
  }

  static Future<Map<String, dynamic>> updateTemplateQuestion(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/template-questions/$id'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw _adminException(response, 'Gagal mengubah soal');
    }
  }

  static Future<void> deleteTemplateQuestion(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/template-questions/$id'),
      headers: _headers(requiresAuth: true),
    );

    if (response.statusCode != 200) {
      throw _adminException(response, 'Gagal menghapus soal');
    }
  }

  static Future<Map<String, dynamic>> storeQuizResult({
    required int quizTemplateId,
    required int score,
    required int correctCount,
    required int totalQuestions,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quiz-results'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode({
        'quiz_template_id': quizTemplateId,
        'score': score,
        'correct_count': correctCount,
        'total_questions': totalQuestions,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }

    throw Exception('Gagal menyimpan hasil quiz');
  }
}
