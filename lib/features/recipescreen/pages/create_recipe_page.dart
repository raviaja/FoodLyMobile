import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:foodly_mobile_frontend/services/api_client.dart';
import 'package:foodly_mobile_frontend/widgets/image_picker_widget.dart';

class CreateRecipePage extends StatefulWidget {
  const CreateRecipePage({super.key});

  @override
  State<CreateRecipePage> createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<TextEditingController> _ingredientControllers = [TextEditingController()];
  List<TextEditingController> _stepControllers = [TextEditingController()];

  String _imageUrl = ''; // diisi oleh ImagePickerWidget
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    for (final c in _ingredientControllers) c.dispose();
    for (final c in _stepControllers) c.dispose();
    super.dispose();
  }

  void _addIngredient() =>
      setState(() => _ingredientControllers.add(TextEditingController()));

  void _removeIngredient(int index) {
    if (_ingredientControllers.length <= 1) return;
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addStep() =>
      setState(() => _stepControllers.add(TextEditingController()));

  void _removeStep(int index) {
    if (_stepControllers.length <= 1) return;
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  Future<void> _submitRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto resep wajib ditambahkan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.dio.post(
        '/recipes',
        data: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'image_url': _imageUrl,
          'calories': int.parse(_caloriesController.text.trim()),
          'ingredients': jsonEncode(
              _ingredientControllers.map((c) => c.text.trim()).toList()),
          'steps':
              jsonEncode(_stepControllers.map((c) => c.text.trim()).toList()),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resep berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Gagal membuat resep.';
      if (e.response?.data is Map &&
          e.response!.data.containsKey('message')) {
        errorMessage = e.response!.data['message'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _caloriesController.clear();
    _descriptionController.clear();
    setState(() {
      _imageUrl = '';
      _ingredientControllers = [TextEditingController()];
      _stepControllers = [TextEditingController()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Resep Baru',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // ── Foto Resep (kamera/galeri) ──
              _buildLabel('Foto Resep *'),
              ImagePickerWidget(
                onImageUrlChanged: (url) => setState(() => _imageUrl = url),
              ),

              // ── Judul ──
              _buildLabel('Judul Resep *'),
              _buildTextField(_titleController, 'Contoh: Nasi Goreng Spesial'),

              // ── Kalori ──
              _buildLabel('Jumlah Kalori *'),
              _buildTextField(_caloriesController, 'Contoh: 450', isNumber: true),

              // ── Deskripsi ──
              _buildLabel('Deskripsi *'),
              _buildTextField(
                _descriptionController,
                'Ceritakan tentang resep Anda...',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // ── Bahan-Bahan ──
              _buildLabel('Bahan-Bahan *'),
              ..._ingredientControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                            entry.value, 'Bahan ${entry.key + 1}'),
                      ),
                      if (_ingredientControllers.length > 1)
                        IconButton(
                          icon:
                              const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeIngredient(entry.key),
                        ),
                    ],
                  ),
                );
              }),
              _buildAddButton('Tambah Bahan', _addIngredient),

              const SizedBox(height: 20),

              // ── Cara Membuat ──
              _buildLabel('Cara Membuat *'),
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
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                            entry.value, 'Langkah ${entry.key + 1}'),
                      ),
                      if (_stepControllers.length > 1)
                        IconButton(
                          icon:
                              const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeStep(entry.key),
                        ),
                    ],
                  ),
                );
              }),
              _buildAddButton('Tambah Langkah', _addStep),

              const SizedBox(height: 40),

              // ── Tombol Aksi ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6900),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Buat Resep',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 10),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.trim().isEmpty ? 'Wajib diisi' : null,
    );
  }

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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}