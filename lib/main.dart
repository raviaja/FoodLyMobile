import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/notif_service.dart';

import 'package:foodly_mobile_frontend/features/homescreen/pages/homepage.dart';
import 'package:foodly_mobile_frontend/features/searchscreen/pages/searchpage.dart';
import 'package:foodly_mobile_frontend/screens/login_screen.dart';
import 'package:foodly_mobile_frontend/features/recipescreen/pages/create_recipe_page.dart';
import 'package:foodly_mobile_frontend/features/favoritscreen/pages/favorit_page.dart';
import 'package:foodly_mobile_frontend/features/homescreen/providers/like_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await NotificationService.setupMealReminders();
  final pending = await NotificationService.notifications.pendingNotificationRequests();

  print("Pending count: ${pending.length}");
  for (final p in pending) {
    print("${p.id} - ${p.title}");
  }

  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6900)),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainPage() : const LoginScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final LikeProvider _likeProvider = LikeProvider();

  // ← GlobalKey untuk mengakses FavoritPageState dari luar
  final GlobalKey<FavoritPageState> _favoritPageKey = GlobalKey<FavoritPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(likeProvider: _likeProvider),
      SearchPage(likeProvider: _likeProvider),
      const CreateRecipePage(),
      FavoritPage(
        key: _favoritPageKey, // ← pasang key di sini
        likeProvider: _likeProvider,
      ),
    ];
  }

  @override
  void dispose() {
    _likeProvider.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // ← Setiap kali tab Favorit (index 3) dipencet, langsung refresh
    if (index == 3) {
      _favoritPageKey.currentState?.refresh();
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Image.asset("lib/assets/icons/logofoodly.png"),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF54900), Color(0xFFE7000B)],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: const Text(
            'Foodly',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.black54),
          ),
        ],
        elevation: 4,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFF6900),
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Buat"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorit"),
        ],
      ),
    );
  }
}