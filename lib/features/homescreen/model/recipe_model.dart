import 'user_model.dart';

class Recipe {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String ingredients;
  final String steps;
  final String imageUrl;
  final int calories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final bool isLiked; // ← BARU: dari field is_liked di BE
  final User user;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.calories,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.user,
    this.isLiked = false, // default false jika tidak ada di response
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      ingredients: json['ingredients'],
      steps: json['steps'],
      imageUrl: json['image_url'],
      calories: json['calories'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] == true, // ← parse dari BE
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'image_url': imageUrl,
      'calories': calories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
      'user': user.toJson(),
    };
  }

  // copyWith agar bisa update isLiked & likesCount tanpa rebuild seluruh objek
  Recipe copyWith({int? likesCount, bool? isLiked}) {
    return Recipe(
      id: id,
      userId: userId,
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      imageUrl: imageUrl,
      calories: calories,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      user: user,
    );
  }
}