import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';
import 'package:foodly_mobile_frontend/features/detailscreen/pages/recipe_detail_page.dart';

class FavoritPage extends StatefulWidget {
  final LikeProvider likeProvider;
  const FavoritPage({super.key, required this.likeProvider});

  @override
  State<FavoritPage> createState() => FavoritPageState();
}

class FavoritPageState extends State<FavoritPage> {
  bool _isLoading = false;
  String? _error;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadFavorites();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _currentUserId = prefs.getInt('user_id') ?? 0);
  }

  // Dipanggil oleh MainPage setiap kali tab Favorit dipencet
  Future<void> refresh() async {
    widget.likeProvider.invalidateFavorites();
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await widget.likeProvider.loadFavorites();
    } catch (_) {
      if (mounted) setState(() => _error = 'Gagal memuat favorit. Coba lagi.');
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
        child: AnimatedBuilder(
          animation: widget.likeProvider,
          builder: (context, _) {
            final List<Recipe> favorites = widget.likeProvider.favorites
                .where((r) => widget.likeProvider.isLiked(r.id))
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFE7000B), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 22),
                    ),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFF54900), Color(0xFFE7000B)],
                        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: const Text(
                          'Resep Favorit Saya',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  _isLoading ? 'Memuat...' : '${favorites.length} resep yang Anda sukai',
                  style: const TextStyle(color: Color(0xFF4A5565)),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6900)))
                      : _error != null
                          ? _buildErrorState()
                          : favorites.isEmpty
                              ? _buildEmptyState()
                              : RefreshIndicator(
                                  onRefresh: refresh,
                                  color: const Color(0xFFFF6900),
                                  child: ListView.separated(
                                    itemCount: favorites.length,
                                    itemBuilder: (context, index) {
                                      final recipe = favorites[index];
                                      return RecipeCard(
                                        id: recipe.id,
                                        name: recipe.title,
                                        user: recipe.user.name,
                                        like: recipe.likesCount,
                                        imageUrl: recipe.imageUrl,
                                        createdAt: recipe.createdAt,
                                        calories: recipe.calories,
                                        isLiked: true,
                                        likeProvider: widget.likeProvider,
                                        onTap: () => _goToDetail(context, recipe.id), // ← navigasi ke detail
                                      );
                                    },
                                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                                  ),
                                ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.red.shade200),
          const SizedBox(height: 20),
          const Text(
            'Belum ada resep favorit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF364153)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai like resep favorit Anda\nuntuk melihatnya di sini',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4A5565)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Color(0xFF4A5565)), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6900),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}