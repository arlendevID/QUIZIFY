import '../api/quiz_api.dart';

class QuizRepository {
  Future<List<dynamic>> getQuizzes() async {
    return await QuizApi.getQuizzes();
  }
}