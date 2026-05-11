import 'package:flutter/material.dart';
import 'package:foodly_mobile_frontend/features/homescreen/pages/homepage.dart';
import 'package:foodly_mobile_frontend/features/searchscreen/presentation/searchpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
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

  final List<Widget> _pages = const [HomePage(), SearchPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(top: 12),
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
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.logout))],
        elevation: 4,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,

        type: BottomNavigationBarType.fixed,

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,

        selectedItemColor: Color(0xFFFF6900),

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
