import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import SharedPreferences
import './services/notif_service.dart';

import 'package:foodly_mobile_frontend/features/homescreen/pages/homepage.dart';
import 'package:foodly_mobile_frontend/features/searchscreen/pages/searchpage.dart';
import 'package:foodly_mobile_frontend/screens/login_screen.dart'; // 2. Pastikan path ini sesuai dengan folder Anda

// IMPORT HALAMAN BUAT RESEP DI SINI:
import 'package:foodly_mobile_frontend/features/recipescreen/pages/create_recipe_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await NotificationService.setupMealReminders();
  final pending = await NotificationService.notifications
      .pendingNotificationRequests();

  print("Pending count: ${pending.length}");

  for (final p in pending) {
    print("${p.id} - ${p.title}");
  }

  // 4. Cek token di memori HP saat aplikasi pertama kali dibuka
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 5. Lempar status login (true/false) ke MyApp
  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // Terima status login dari main()

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodly',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6900)),
        useMaterial3: true,
      ),
      // 6. LOGIKA ROUTING UTAMA:
      // Pastikan menggunakan pengecekan isLoggedIn agar aman
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

  // 7. Masukkan CreateRecipePage ke dalam daftar halaman
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    CreateRecipePage(), // <--- HALAMAN BUAT RESEP SUDAH AKTIF
    Center(child: Text("Halaman Favorit belum dibuat")), // Index 3 (Favorit)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 8. FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token dari memori

    if (mounted) {
      // Pindah paksa ke halaman Login dan hapus riwayat tombol "Back"
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
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // 9. Pasang fungsi logout ke tombol
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