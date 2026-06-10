import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/services/recipe_service.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/widgets/recipe_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final RecipeService recipeService = RecipeService();

  List<Recipe> searchResult = [];

  final TextEditingController inputController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    getTheLatestRecipes();
  }

  Future<void> getTheLatestRecipes() async {
    final result = await recipeService.getLatestRecipes();

    setState(() {
      searchResult = result;
    });
  }

  Future<void> searchForRecipe(String nama, String kategori, String urutan) async {
    final result = await recipeService.searchRecipe(nama, kategori.toLowerCase(), urutan.toLowerCase());

    setState(() {
      searchResult = result;
    });
  }

  String kategori = "Like";

  String urutan = "Descending";

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
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        const LinearGradient(
                          colors: [Color(0xFFF54900), Color(0xFFE7000B)],
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),

                    child: const Text(
                      'Cari Resep',
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

            SizedBox(height: 15),

            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
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
                            // warna background input
                            filled: true,
                            fillColor: Color(0xFFF3F3F5),

                            // warna label text
                            labelStyle: TextStyle(color: Color(0xFF717182)),

                            // border normal
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFFFD6A8),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            // border saat diklik/focus
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFFFD6A8),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 10),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, 45),
                          backgroundColor: Color(0xFFFF6900),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          String input = inputController.text;
                          searchForRecipe(input, kategori, urutan);
                        },
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Cari", style: TextStyle(color: Colors.white), ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.tune, color: Color(0xFFF54900)),
                      SizedBox(width: 10),
                      Text(
                        "Filter:",
                        style: TextStyle(
                          color: Color(0xFF364153),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(width: 15),

                      DropdownButton<String>(
                        value: kategori,
                        items: ["Like", "Tanggal", "Kalori"]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(color: Color(0xFF0A0A0A)),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            kategori = value!;
                          });
                        },
                      ),

                      SizedBox(width: 15),

                      DropdownButton<String>(
                        value: urutan,
                        items: ["Descending", "Ascending"]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(color: Color(0xFF0A0A0A)),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            urutan = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            Expanded(
              child: ListView.separated(
                itemCount: searchResult.length,
                itemBuilder: (context, index) {
                  final Recipe recipe = searchResult[index];

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
