import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
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

            SizedBox(height: 25),

            RecipeCard()
          ],
        ),
      ),
    );
  }
}
