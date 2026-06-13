import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:foodly_mobile_frontend/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk input biasa
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // List Controller untuk Bahan dan Langkah (Dinamis)
  List<TextEditingController> _ingredientControllers = [TextEditingController()];
  List<TextEditingController> _stepControllers = [TextEditingController()];

  bool _isLoading = false;

  // Fungsi menambah field bahan
  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  // Fungsi menambah field langkah
  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  // Fungsi kirim data ke Backend Render
  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Siapkan data sesuai struktur yang diminta Laravel
      Map<String, dynamic> recipeData = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "image_url": _imageUrlController.text,
        "calories": int.parse(_caloriesController.text),
        
        // Bungkus List menjadi String menggunakan jsonEncode
        "ingredients": jsonEncode(_ingredientControllers.map((c) => c.text).toList()),
        "steps": jsonEncode(_stepControllers.map((c) => c.text).toList()),
      };

      final response = await ApiClient.dio.post(
        '/recipes',
        data: recipeData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Resep berhasil dibuat!"),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form setelah berhasil submit
        _titleController.clear();
        _imageUrlController.clear();
        _caloriesController.clear();
        _descriptionController.clear();
        setState(() {
          _ingredientControllers = [TextEditingController()];
          _stepControllers = [TextEditingController()];
        });
      }
    } on DioException catch (e) {
      String errorMessage = "Gagal membuat resep.";
      
      if (e.response != null && e.response?.data != null) {
        final backendData = e.response?.data;
        
        print("=== DETEKSI ERROR VALIDASI LARAVEL ===");
        print(backendData);
        print("=======================================");
        
        if (backendData is Map && backendData.containsKey('message')) {
          errorMessage = backendData['message'];
        } else {
          errorMessage = backendData.toString();
        }
      } else {
        errorMessage = "Error koneksi: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error umum: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat resep: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // TOMBOL KEMBALI SUDAH DIHAPUS DARI SINI
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Resep Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // Judul Resep
              _buildLabel("Judul Resep *"),
              _buildTextField(_titleController, "Contoh: Nasi Goreng Spesial"),

              // URL Gambar
              _buildLabel("URL Gambar *"),
              _buildTextField(_imageUrlController, "https://example.com/image.jpg", icon: Icons.link),

              // Kalori
              _buildLabel("Jumlah Kalori *"),
              _buildTextField(_caloriesController, "Contoh: 450", isNumber: true),

              // Deskripsi
              _buildLabel("Deskripsi *"),
              _buildTextField(_descriptionController, "Ceritakan tentang resep Anda...", maxLines: 3),

              const SizedBox(height: 20),

              // --- BAGIAN BAHAN-BAHAN ---
              _buildLabel("Bahan-Bahan *"),
              ..._ingredientControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTextField(entry.value, "Bahan ${entry.key + 1}"),
                );
              }).toList(),
              _buildAddButton("Tambah Bahan", _addIngredient),

              const SizedBox(height: 20),

              // --- BAGIAN CARA MEMBUAT ---
              _buildLabel("Cara Membuat *"),
              ..._stepControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6900),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(entry.value, "Langkah ${entry.key + 1}")),
                    ],
                  ),
                );
              }).toList(),
              _buildAddButton("Tambah Langkah", _addStep),

              const SizedBox(height: 40),

              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Mengosongkan form jika klik Batal
                        _titleController.clear();
                        _imageUrlController.clear();
                        _caloriesController.clear();
                        _descriptionController.clear();
                        setState(() {
                          _ingredientControllers = [TextEditingController()];
                          _stepControllers = [TextEditingController()];
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Batal", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6900),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Buat Resep", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // Widget Helper untuk TextField
  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
    );
  }

  // Widget Helper untuk Tombol Tambah
  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.black54),
        label: Text(text, style: const TextStyle(color: Colors.black54)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF1F5F9),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}