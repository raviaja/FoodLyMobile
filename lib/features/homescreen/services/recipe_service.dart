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

  // Gabungan: logic mapping dari teman + URL endpoint dari kamu
  Future<List<Recipe>> searchRecipe(
      String name, String kategori, String urutan) async {

    // Map label UI → nama kolom di BE (dari teman)
    String sortBy;
    switch (kategori) {
      case 'Tanggal':
        sortBy = 'created_at';
        break;
      case 'Kalori':
        sortBy = 'calories';
        break;
      default: // 'Like'
        sortBy = 'likes_count';
        break;
    }

    // Map label UI → asc/desc (dari teman)
    final sortOrder = (urutan == 'Ascending') ? 'asc' : 'desc';

    final response = await http.get(
      Uri.parse(
        'https://foodly-backend-5mci.onrender.com/api/recipes?search=$name&sort_by=$sortBy&sort_order=$sortOrder',
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

  Future<Recipe> getDetail(int id) async {
    final response = await ApiClient.dio.get('recipes/$id');
    return Recipe.fromJson(response.data);
  }

  Future<void> updateRecipe(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.put('recipes/$id', data: data);
  }

  Future<void> deleteRecipe(int id) async {
    await ApiClient.dio.delete('recipes/$id');
  }
}