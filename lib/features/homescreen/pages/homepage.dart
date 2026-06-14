import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';
import '../services/recipe_service.dart';
import '../model/recipe_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final RecipeService recipeService = RecipeService();

  List<Recipe> top5 = [];

  @override
  void initState() {
    super.initState();

    fetchRecipeTop5();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    fetchRecipeTop5();
  }

  Future<void> fetchRecipeTop5() async {
    final result = await recipeService.getTop5();

    setState(() {
      top5 = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        width: double.infinity,
        decoration: BoxDecoration(color: Color(0xFFFFF7ED)),

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

                    child: const Text(
                      'Happy Cooking, faisal!',
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

            SizedBox(height: 10),

            Text(
              "Temukan resep favorit dan mulai memasak hari ini",
              style: TextStyle(color: Color(0xFF4A5565)),
            ),

            SizedBox(height: 20),

            Row(
              spacing: 10,
              children: [
                Image.asset('lib/assets/icons/IconRising.png'),
                Text(
                  'Recipe of the Week',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            Text(
              "5 resep terbaik berdasarkan jumlah like dalam 7 hari terakhir",
              style: TextStyle(color: Color(0xFF4A5565)),
            ),

            SizedBox(height: 15),

            Expanded(
              child: ListView.separated(
                itemCount: top5.length,
                itemBuilder: (context, index) {
                  final Recipe recipe = top5[index];

                  return RecipeCard(
                    id: recipe.id,
                    name: recipe.title,
                    user: recipe.user.name,
                    like: recipe.likesCount,
                    imageUrl: recipe.imageUrl,
                    createdAt: recipe.createdAt,
                    calories: recipe.calories,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
