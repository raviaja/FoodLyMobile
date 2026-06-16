import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:foodly_mobile_frontend/services/api_client.dart';
import '../model/recipe_model.dart';

class RecipeService {
  // ── Tanpa token (public) ──

  Future<List<Recipe>> getTop5() async {
    final response = await http.get(
      Uri.parse('https://foodly-backend-5mci.onrender.com/api/recipes/top/best'),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load top recipes');
  }

  Future<List<Recipe>> getLatestRecipes() async {
    final response = await http.get(
      Uri.parse('https://foodly-backend-5mci.onrender.com/api/recipes/latest'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final List data = result['data'];
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to load recipes');
  }

  Future<List<Recipe>> searchRecipe(
      String name, String kategori, String urutan) async {
    final response = await http.get(
      Uri.parse(
        'https://foodly-backend-5mci.onrender.com/api/recipes?search=$name&kategori=$kategori&sort=$urutan',
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      final List data = result['data'];
      return data.map((json) => Recipe.fromJson(json)).toList();
    }
    throw Exception('Failed to search recipes');
  }

  // ── Dengan token (pakai Dio via ApiClient) ──

  // GET /recipes/{id} — detail resep + is_liked dari server
  Future<Recipe> getDetail(int id) async {
    final response = await ApiClient.dio.get('recipes/$id');
    return Recipe.fromJson(response.data);
  }

  // PUT /recipes/{id} — update resep milik sendiri
  Future<void> updateRecipe(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.put('recipes/$id', data: data);
  }

  // DELETE /recipes/{id} — hapus resep milik sendiri
  Future<void> deleteRecipe(int id) async {
    await ApiClient.dio.delete('recipes/$id');
  }
}