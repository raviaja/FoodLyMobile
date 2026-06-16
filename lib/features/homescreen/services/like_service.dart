import 'package:foodly_mobile_frontend/services/api_client.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';

class LikeService {
  // Toggle like/unlike — endpoint: POST /recipes/{id}/like
  Future<Map<String, dynamic>> toggleLike(int recipeId) async {
    final response = await ApiClient.dio.post('recipes/$recipeId/like');
    return {
      'is_liked': response.data['is_liked'] as bool,
      'likes_count': response.data['likes_count'] as int,
    };
  }

  // Ambil semua resep yang di-like — endpoint: GET /likes
  Future<List<Recipe>> getFavorites() async {
    final response = await ApiClient.dio.get('likes'); // ← fix: /likes bukan /recipes/favorites

    // Response BE: { data: [...], current_page: ..., ... } (pagination)
    final List data = response.data['data'];
    return data.map((json) => Recipe.fromJson(json)).toList();
  }
}