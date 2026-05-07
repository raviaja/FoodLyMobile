import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/Pages/searchpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Home"));
  }
}