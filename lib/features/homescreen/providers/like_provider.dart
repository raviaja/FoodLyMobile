import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/services/like_service.dart';

/// LikeProvider adalah "single source of truth" untuk status like.
/// Semua page (Home, Search, Favorit) mendengarkan provider ini.
/// Ketika like berubah di satu page, semua page otomatis ikut update.
class LikeProvider extends ChangeNotifier {
  final LikeService _likeService = LikeService();

  // Map<recipeId, {isLiked, likesCount}>
  final Map<int, Map<String, dynamic>> _likeState = {};

  // Cache daftar favorit
  List<Recipe> _favorites = [];
  bool _favoritesLoaded = false;

  List<Recipe> get favorites => _favorites;
  bool get favoritesLoaded => _favoritesLoaded;

  // ── Ambil status like untuk satu resep ──
  bool isLiked(int recipeId) {
    return _likeState[recipeId]?['is_liked'] ?? false;
  }

  int likesCount(int recipeId, int fallback) {
    return _likeState[recipeId]?['likes_count'] ?? fallback;
  }

  // ── Inisialisasi status like dari list resep (dipanggil setelah fetch) ──
  void initFromRecipes(List<Recipe> recipes) {
    for (final r in recipes) {
      // Hanya set jika belum ada (jangan overwrite state yang sudah di-toggle)
      _likeState.putIfAbsent(r.id, () => {
        'is_liked': r.isLiked,
        'likes_count': r.likesCount,
      });
    }
    // Tidak perlu notifyListeners() di sini karena ini dipanggil saat build
  }

  // ── Toggle like ──
  Future<void> toggleLike(int recipeId) async {
    // Optimistic update
    final current = _likeState[recipeId];
    final wasLiked = current?['is_liked'] ?? false;
    final prevCount = current?['likes_count'] ?? 0;

    _likeState[recipeId] = {
      'is_liked': !wasLiked,
      'likes_count': prevCount + (!wasLiked ? 1 : -1),
    };
    notifyListeners();

    try {
      final result = await _likeService.toggleLike(recipeId);
      _likeState[recipeId] = {
        'is_liked': result['is_liked'],
        'likes_count': result['likes_count'],
      };

      // Sinkronkan favorit:
      // - Jika baru di-like, tambahkan ke cache favorit (jika sudah dimuat)
      // - Jika di-unlike, hapus dari cache favorit
      if (_favoritesLoaded) {
        if (result['is_liked'] == false) {
          _favorites.removeWhere((r) => r.id == recipeId);
        }
        // Jika di-like, biarkan FavoritPage refresh sendiri saat dibuka
      }

      notifyListeners();
    } catch (e) {
      // Rollback jika gagal
      _likeState[recipeId] = {
        'is_liked': wasLiked,
        'likes_count': prevCount,
      };
      notifyListeners();
      rethrow; // lempar ke UI agar bisa tampilkan SnackBar
    }
  }

  // ── Load favorit dari server ──
  Future<void> loadFavorites() async {
    _favorites = await _likeService.getFavorites();
    _favoritesLoaded = true;

    // Sinkronkan status like dari data favorit
    for (final r in _favorites) {
      _likeState[r.id] = {
        'is_liked': true,
        'likes_count': r.likesCount,
      };
    }
    notifyListeners();
  }

  // ── Reset favorit agar di-reload saat dibuka lagi ──
  void invalidateFavorites() {
    _favoritesLoaded = false;
    notifyListeners();
  }
}