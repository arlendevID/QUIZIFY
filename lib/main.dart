import 'package:flutter/material.dart';

import 'app.dart';
import 'services/repository/category_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  CategoryRepository().getCategories().then((data) {
    print('DATA CATEGORY DARI LARAVEL: $data');
  }).catchError((error) {
    print('ERROR AMBIL CATEGORY: $error');
  });

  runApp(const QuizifyApp());
}