import 'package:flutter/material.dart';

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
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9)),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Image.asset('lib/assets/icons/IconStar.png'),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      const LinearGradient(
                        colors: [Color(0xFFF54900), Color(0xFFE7000B)],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),

                  child: const Text(
                    'Happy Cooking, faisal!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10,),
            
            Text(
              "Temukan resep favorit dan mulai memasak hari ini",
              style: TextStyle(
                color: Color(0xFF4A5565)
              ),
            )
          ],
        ),
      ),
    );
  }
}
