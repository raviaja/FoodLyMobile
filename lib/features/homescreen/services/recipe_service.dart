import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/recipe_model.dart';

class RecipeService {
  Future<List<Recipe>> getTop5() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/recipes/top/best'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((json) => Recipe.fromJson(json)).toList();
    }

    throw Exception('Failed to load recipes');
  }

  Future<List<Recipe>> searchRecipe(
    String name,
    String kategori,
    String urutan,
  ) async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8000/api/recipes?search=$name&kategori=$kategori&sort=$urutan',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);

      final List data = result['data'];

      return data.map((json) => Recipe.fromJson(json)).toList();
    }

    throw Exception('Failed to load recipes');
  }
}
