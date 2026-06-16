import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';
import 'package:foodly_mobile_frontend/features/detailscreen/pages/recipe_detail_page.dart';
import '../services/recipe_service.dart';
import '../model/recipe_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final LikeProvider likeProvider;
  const HomePage({super.key, required this.likeProvider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RecipeService recipeService = RecipeService();
  List<Recipe> top5 = [];
  bool _isLoading = true;
  int _currentUserId = 0;
  User user = User(id: -1, name: '', email: '', createdAt: DateTime.now(), updatedAt: DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchRecipeTop5();
    getTheUser();
  }

  // didPopNext() DIHAPUS — tidak valid di State biasa,
  // dan tidak dibutuhkan karena IndexedStack tidak push/pop route.
  // Refresh otomatis sudah ditangani oleh LikeProvider (AnimatedBuilder).

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentUserId = prefs.getInt('user_id') ?? 0);
  }

  Future<void> getTheUser() async {
    final result = await getUser();
    setState(() {
      user = result;
    });
  }

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('https://foodly-backend-5mci.onrender.com/api/me'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return User.fromJson(json);
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  Future<void> fetchRecipeTop5() async {
    setState(() => _isLoading = true);
    try {
      final result = await recipeService.getTop5();
      widget.likeProvider.initFromRecipes(result);
      setState(() => top5 = result);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToDetail(BuildContext context, int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(
          recipeId: recipeId,
          currentUserId: _currentUserId,
          likeProvider: widget.likeProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Image.asset('lib/assets/icons/IconStar.png'),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          colors: [Color(0xFFF54900), Color(0xFFE7000B)],
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      'Happy Cooking, ${user.name}!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Text(
              'Temukan resep favorit dan mulai memasak hari ini',
              style: TextStyle(color: Color(0xFF4A5565)),
            ),
            const SizedBox(height: 20),

            Row(
              spacing: 10,
              children: [
                Image.asset('lib/assets/icons/IconRising.png'),
                const Text(
                  'Recipe of the Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Text(
              '5 resep terbaik berdasarkan jumlah like dalam 7 hari terakhir',
              style: TextStyle(color: Color(0xFF4A5565)),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6900),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: widget.likeProvider,
                      builder: (context, _) {
                        return ListView.separated(
                          itemCount: top5.length,
                          itemBuilder: (context, index) {
                            final recipe = top5[index];
                            return RecipeCard(
                              id: recipe.id,
                              name: recipe.title,
                              user: recipe.user.name,
                              like: recipe.likesCount,
                              imageUrl: recipe.imageUrl,
                              createdAt: recipe.createdAt,
                              calories: recipe.calories,
                              isLiked: recipe.isLiked,
                              likeProvider: widget.likeProvider,
                              onTap: () => _goToDetail(context, recipe.id),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 15),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
