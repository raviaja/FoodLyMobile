import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:foodly_mobile_frontend/features/homescreen/model/recipe_model.dart';
import 'package:foodly_mobile_frontend/features/homescreen/services/recipe_service.dart';
import 'package:foodly_mobile_frontend/widgets/image_picker_widget.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;
  const EditRecipePage({super.key, required this.recipe});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _recipeService = RecipeService();

  late final TextEditingController _titleController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _descriptionController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;

  late String _imageUrl; // diupdate oleh ImagePickerWidget
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _caloriesController =
        TextEditingController(text: widget.recipe.calories.toString());
    _descriptionController =
        TextEditingController(text: widget.recipe.description);
    _imageUrl = widget.recipe.imageUrl;
    _ingredientControllers = _parseJsonToControllers(widget.recipe.ingredients);
    _stepControllers = _parseJsonToControllers(widget.recipe.steps);
  }

  List<TextEditingController> _parseJsonToControllers(String raw) {
    try {
      final List list = jsonDecode(raw);
      if (list.isEmpty) return [TextEditingController()];
      return list
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
    } catch (_) {
      // Fallback: split per koma (format web)
      final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.isEmpty) return [TextEditingController()];
      return parts.map((e) => TextEditingController(text: e)).toList();
    }
  }

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

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto resep tidak boleh kosong.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _recipeService.updateRecipe(widget.recipe.id, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': _imageUrl,
        'calories': int.parse(_caloriesController.text.trim()),
        'ingredients': jsonEncode(
            _ingredientControllers.map((c) => c.text.trim()).toList()),
        'steps':
            jsonEncode(_stepControllers.map((c) => c.text.trim()).toList()),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Resep berhasil diupdate!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      String msg = 'Gagal mengupdate resep.';
      if (e.response?.data is Map &&
          e.response!.data.containsKey('message')) {
        msg = e.response!.data['message'];
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Resep',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto Resep ──
              _buildLabel('Foto Resep *'),
              ImagePickerWidget(
                initialImageUrl: _imageUrl, // tampilkan foto lama
                onImageUrlChanged: (url) => setState(() => _imageUrl = url),
              ),

              // ── Judul ──
              _buildLabel('Judul Resep *'),
              _buildTextField(_titleController, 'Contoh: Nasi Goreng Spesial'),

              // ── Kalori ──
              _buildLabel('Jumlah Kalori *'),
              _buildTextField(_caloriesController, 'Contoh: 450',
                  isNumber: true),

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
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
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
                        child: Text('${entry.key + 1}',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                            entry.value, 'Langkah ${entry.key + 1}'),
                      ),
                      if (_stepControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _isLoading ? null : _submitEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6900),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Perubahan',
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