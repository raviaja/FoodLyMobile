import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecipeCard extends StatefulWidget {
  final String name;
  final int id;
  final String user;
  final int like;
  final String imageUrl;
  final DateTime createdAt;
  final int calories;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.id,
    required this.name,
    required this.user,
    required this.like,
    required this.imageUrl,
    required this.createdAt,
    required this.calories,
    this.onTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'oleh ${widget.user}',
                style: const TextStyle(
                  color: Color(0xFF4A5565),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Image.asset("lib/assets/icons/FavoriteIcon.png"),

                  const SizedBox(width: 5),

                  Text(
                    widget.like.toString(),
                    style: const TextStyle(color: Color(0xFF4A5565)),
                  ),

                  const SizedBox(width: 10),

                  Image.asset("lib/assets/icons/CalIcon.png"),

                  const SizedBox(width: 5),

                  Text(
                    "${widget.calories} kal",
                    style: const TextStyle(color: Color(0xFF4A5565)),
                  ),

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