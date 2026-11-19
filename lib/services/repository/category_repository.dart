import '../api/category_api.dart';

class CategoryRepository {
  Future<List<dynamic>> getCategories() async {
    return await CategoryApi.getCategories();
  }
}