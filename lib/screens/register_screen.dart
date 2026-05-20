import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../widgets/custom_input.dart';
import 'login_screen.dart';
import '../main.dart'; // 1. Tambahkan import ini untuk memanggil MainPage

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    // Validasi Manual
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = "Konfirmasi password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.dio.post('/register', data: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmController.text,
      });

      final token = response.data['token'] ?? response.data['data']['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil!"), backgroundColor: Colors.green),
        );
        // 2. AKTIFKAN NAVIGASI: Pindah ke MainPage setelah register sukses
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } on DioException catch (e) {
      setState(() {
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          _errorMessage = errors.values.first[0]; // Ambil error pertama dari Laravel
        } else {
          _errorMessage = e.response?.data['message'] ?? "Registrasi Gagal.";
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFFF6900),
                  child: Icon(Icons.restaurant_menu, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF6900), Color(0xFFFB2C36)],
                  ).createShader(bounds),
                  child: const Text("Foodly", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const Text("Buat akun baru", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(10)),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),

                CustomInput(hintText: "Username", icon: Icons.person_outline, controller: _nameController),
                CustomInput(hintText: "Email", icon: Icons.email_outlined, controller: _emailController),
                CustomInput(hintText: "Password", icon: Icons.lock_outline, isPassword: true, controller: _passwordController),
                CustomInput(hintText: "Konfirmasi Password", icon: Icons.lock_outline, isPassword: true, controller: _confirmController),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6900),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text("Login", style: TextStyle(color: Color(0xFFFF6900), fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}