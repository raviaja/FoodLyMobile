import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';

class RecipeCard extends StatefulWidget {
  final int id;
  final String name;
  final String user;
  final int like;
  final String imageUrl;
  final DateTime createdAt;
  final int calories;
  final bool isLiked;
  final LikeProvider likeProvider;
  final VoidCallback? onTap; // ← onTap diisi dari parent (navigasi ke detail)

  const RecipeCard({
    super.key,
    required this.id,
    required this.name,
    required this.user,
    required this.like,
    required this.imageUrl,
    required this.createdAt,
    required this.calories,
    required this.isLiked,
    required this.likeProvider,
    this.onTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isLoading = false;

  Future<void> _toggleLike() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.likeProvider.toggleLike(widget.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah like. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLiked = widget.likeProvider.isLiked(widget.id);
    final int likesCount = widget.likeProvider.likesCount(widget.id, widget.like);

    return InkWell(
      onTap: widget.onTap, // ← tap card → navigasi ke detail
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
                    ),
                  ),
                ),
                // Tombol like di pojok kanan atas gambar
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleLike,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE7000B)),
                            )
                          : Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? const Color(0xFFE7000B) : Colors.grey,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'oleh ${widget.user}',
                style: const TextStyle(color: Color(0xFF4A5565)),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? const Color(0xFFE7000B) : const Color(0xFF4A5565),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(likesCount.toString(), style: const TextStyle(color: Color(0xFF4A5565))),
                  const SizedBox(width: 10),
                  Image.asset("lib/assets/icons/CalIcon.png"),
                  const SizedBox(width: 5),
                  Text("${widget.calories} kal", style: const TextStyle(color: Color(0xFF4A5565))),
                  const SizedBox(width: 10),
                  Image.asset("lib/assets/icons/DateIcon.png"),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.createdAt),
                    style: const TextStyle(color: Color(0xFF4A5565)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}