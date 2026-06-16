import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodly_mobile_frontend/features/homescreen/services/recipe_service.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';
import 'package:foodly_mobile_frontend/features/detailscreen/pages/recipe_detail_page.dart';

class SearchPage extends StatefulWidget {
  final LikeProvider likeProvider;
  const SearchPage({super.key, required this.likeProvider});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final RecipeService recipeService = RecipeService();
  List<Recipe> searchResult = [];
  final TextEditingController inputController = TextEditingController();
  String kategori = "Like";
  String urutan = "Descending";
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    getTheLatestRecipes();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentUserId = prefs.getInt('user_id') ?? 0);
  }

  Future<void> getTheLatestRecipes() async {
    final result = await recipeService.getLatestRecipes();
    widget.likeProvider.initFromRecipes(result);
    setState(() => searchResult = result);
  }

  Future<void> searchForRecipe(String nama, String kategori, String urutan) async {
    final result = await recipeService.searchRecipe(
        nama, kategori.toLowerCase(), urutan.toLowerCase());
    widget.likeProvider.initFromRecipes(result);
    setState(() => searchResult = result);
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
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFF54900), Color(0xFFE7000B)],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Text(
                'Cari Resep',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            labelText: "Masukkan nama resep",
                            filled: true,
                            fillColor: const Color(0xFFF3F3F5),
                            labelStyle: const TextStyle(color: Color(0xFF717182)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFFFD6A8), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFFFFD6A8), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 45),
                          backgroundColor: const Color(0xFFFF6900),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => searchForRecipe(inputController.text, kategori, urutan),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Cari", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Color(0xFFF54900)),
                      const SizedBox(width: 10),
                      const Text("Filter:", style: TextStyle(color: Color(0xFF364153), fontWeight: FontWeight.w500)),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        value: kategori,
                        items: ["Like", "Tanggal", "Kalori"].map((item) =>
                          DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Color(0xFF0A0A0A))))).toList(),
                        onChanged: (value) => setState(() => kategori = value!),
                      ),
                      const SizedBox(width: 15),
                      DropdownButton<String>(
                        value: urutan,
                        items: ["Descending", "Ascending"].map((item) =>
                          DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Color(0xFF0A0A0A))))).toList(),
                        onChanged: (value) => setState(() => urutan = value!),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: AnimatedBuilder(
                animation: widget.likeProvider,
                builder: (context, _) {
                  return ListView.separated(
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      final recipe = searchResult[index];
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
                        onTap: () => _goToDetail(context, recipe.id), // ← navigasi ke detail
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
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