import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/services/recipe_service.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';
import 'package:foodly_mobile_frontend/features/recipescreen/pages/edit_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final int currentUserId;
  final LikeProvider likeProvider;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.currentUserId,
    required this.likeProvider,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final RecipeService _recipeService = RecipeService();

  Recipe? _recipe;
  bool _isLoading = true;
  bool _isLikeLoading = false;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final recipe = await _recipeService.getDetail(widget.recipeId);
      widget.likeProvider.initFromRecipes([recipe]);
      setState(() => _recipe = recipe);
    } catch (_) {
      setState(() => _error = 'Gagal memuat detail resep.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;
    setState(() => _isLikeLoading = true);
    try {
      await widget.likeProvider.toggleLike(widget.recipeId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah like. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLikeLoading = false);
    }
  }

  Future<void> _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: const Text('Yakin ingin menghapus resep ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      await _recipeService.deleteRecipe(widget.recipeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil dihapus.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, 'deleted');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus resep.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _openEdit() async {
    if (_recipe == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditRecipePage(recipe: _recipe!)),
    );
    if (result == true) _loadDetail();
  }

  /// Parse ingredients/steps yang bisa datang dalam 2 format berbeda:
  ///
  /// Format 1 - JSON array (dari mobile): '["Jukut","Minyak","Garam"]'
  ///   → hasil: ['Jukut', 'Minyak', 'Garam']
  ///
  /// Format 2 - Plain string dipisah koma (dari web): 'daging wagyu, minyak zaitun, mentega'
  ///   → hasil: ['daging wagyu', 'minyak zaitun', 'mentega']
  List<String> _parseList(String raw) {
    if (raw.trim().isEmpty) return [];

    // Coba parse sebagai JSON array dulu
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
    } catch (_) {
      // Bukan JSON — lanjut ke fallback
    }

    // Fallback: coba split per newline dulu (format multi-baris)
    final byNewline = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (byNewline.length > 1) return byNewline;

    // Fallback terakhir: split per koma
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6900)))
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final recipe = _recipe!;
    final ingredients = _parseList(recipe.ingredients);
    final steps = _parseList(recipe.steps);
    final isOwner = recipe.userId == widget.currentUserId;

    return AnimatedBuilder(
      animation: widget.likeProvider,
      builder: (context, _) {
        final isLiked = widget.likeProvider.isLiked(recipe.id);
        final likesCount = widget.likeProvider.likesCount(recipe.id, recipe.likesCount);

        return CustomScrollView(
          slivers: [
            // ── AppBar dengan foto resep ──
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              actions: isOwner
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFFF6900), size: 20),
                            tooltip: 'Edit Resep',
                            onPressed: _openEdit,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: _isDeleting
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  tooltip: 'Hapus Resep',
                                  onPressed: _deleteRecipe,
                                ),
                        ),
                      ),
                    ]
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: recipe.imageUrl.isNotEmpty
                    ? Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      )
                    : Container(color: Colors.grey[200]),
              ),
            ),

            // ── Isi konten ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE7000B),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Penulis
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF4A5565)),
                        const SizedBox(width: 4),
                        Text('oleh ${recipe.user.name}',
                            style: const TextStyle(color: Color(0xFF4A5565))),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Info: kalori | like | tanggal
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _infoChip(
                          icon: Icons.local_fire_department,
                          iconColor: const Color(0xFFFF6900),
                          label: '${recipe.calories} kalori',
                        ),
                        _infoChip(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          iconColor: isLiked ? const Color(0xFFE7000B) : const Color(0xFF4A5565),
                          label: '$likesCount like',
                        ),
                        _infoChip(
                          icon: Icons.calendar_today,
                          iconColor: const Color(0xFF4A5565),
                          label: DateFormat('dd MMM yyyy').format(recipe.createdAt),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tombol Suka
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleLike,
                        icon: _isLikeLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: Colors.white,
                              ),
                        label: Text(
                          isLiked ? 'Tidak Suka' : 'Suka',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLiked ? const Color(0xFFE7000B) : const Color(0xFFFF6900),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Deskripsi
                    _buildSectionTitle('Deskripsi'),
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: const TextStyle(color: Color(0xFF4A5565), height: 1.5),
                    ),

                    const SizedBox(height: 24),

                    // Bahan-Bahan
                    _buildSectionTitle('Bahan-Bahan'),
                    const SizedBox(height: 12),
                    ...ingredients.asMap().entries.map(
                          (e) => _buildIngredientItem(e.key, e.value),
                        ),

                    const SizedBox(height: 24),

                    // Cara Membuat
                    _buildSectionTitle('Cara Membuat'),
                    const SizedBox(height: 12),
                    ...steps.asMap().entries.map(
                          (e) => _buildStepItem(e.key, e.value),
                        ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoChip({required IconData icon, required Color iconColor, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF4A5565))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildIngredientItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: Color(0xFFFF6900), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF364153))),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6900),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text,
                  style: const TextStyle(color: Color(0xFF364153), height: 1.5)),
            ),
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
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Color(0xFF4A5565))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDetail,
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