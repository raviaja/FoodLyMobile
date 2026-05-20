import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class RecipeCard extends StatelessWidget {
  
  final String name;
  final String user;
  final int like;
  final DateTime createdAt;
  final int calories;

  const RecipeCard({
    super.key,
    required this.name,
    required this.user,
    required this.like,
    required this.createdAt,
    required this.calories,
  });




  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              "lib/assets/images/nasiGoreng.jpg",
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(height: 35),

          Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ),

          SizedBox(height: 10),

          Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Text(
              'oleh $user',
              style: TextStyle(color: Color(0xFF4A5565)),
            ),
          ),

          SizedBox(height: 8),

          Padding(
            padding: EdgeInsetsGeometry.only(left: 20),
            child: Row(
              children: [
                Image.asset("lib/assets/icons/FavoriteIcon.png"),

                SizedBox(width: 5,),

                Text(like.toString(), style: TextStyle(color: Color(0xFF4A5565))),

                SizedBox(width: 10,),

                Image.asset("lib/assets/icons/CalIcon.png"),

                SizedBox(width: 5,),

                Text("$calories kal", style: TextStyle(color: Color(0xFF4A5565))),

                SizedBox(width: 10,),

                Image.asset("lib/assets/icons/DateIcon.png"),

                SizedBox(width: 5,),

                Text(DateFormat('dd/MM/yyyy').format(createdAt).toString(), style: TextStyle(color: Color(0xFF4A5565))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
