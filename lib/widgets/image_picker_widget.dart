import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodly_mobile_frontend/services/image_upload_service.dart';

/// Widget reusable untuk pilih foto dari kamera/galeri + upload ke Cloudinary.
/// Dipakai di create_recipe_page dan edit_recipe_page.
///
/// Cara pakai:
/// ```dart
/// ImagePickerWidget(
///   initialImageUrl: 'https://...', // opsional, untuk edit
///   onImageUrlChanged: (url) {
///     setState(() => _imageUrlController.text = url);
///   },
/// )
/// ```
class ImagePickerWidget extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<String> onImageUrlChanged; // dipanggil setelah upload selesai

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUrlChanged,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  File? _localFile;        // file lokal sebelum upload
  String? _uploadedUrl;    // URL setelah berhasil upload
  bool _isUploading = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.initialImageUrl;
  }

  // Tampilkan bottom sheet pilih sumber foto
  Future<void> _showSourcePicker() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6900),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                ),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF364153),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.white, size: 22),
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              // Opsi hapus foto jika sudah ada gambar
              if (_localFile != null || (_uploadedUrl != null && _uploadedUrl!.isNotEmpty))
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 22),
                  ),
                  title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _localFile = null;
                      _uploadedUrl = null;
                      _uploadError = null;
                    });
                    widget.onImageUrlChanged('');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (picked == null) return; // user batal

      final file = File(picked.path);
      setState(() {
        _localFile = file;
        _isUploading = true;
        _uploadError = null;
        _uploadedUrl = null;
      });

      // Upload ke Cloudinary
      final url = await ImageUploadService.uploadImage(file);

      setState(() {
        _uploadedUrl = url;
        _isUploading = false;
      });

      widget.onImageUrlChanged(url); // beri tahu parent
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadError = 'Gagal mengupload foto. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSourcePicker,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _uploadError != null ? Colors.red : const Color(0xFFFFD6A8),
            width: 1.5,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Sedang upload
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF6900)),
          const SizedBox(height: 12),
          const Text('Mengupload foto...', style: TextStyle(color: Color(0xFF4A5565))),
          if (_localFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _localFile!,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      );
    }

    // Sudah ada gambar (dari upload atau initial URL)
    final imageUrl = _uploadedUrl ?? widget.initialImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _localFile != null
                ? Image.file(_localFile!, fit: BoxFit.cover)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
          ),
          // Overlay edit
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Ganti Foto', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Error upload
    if (_uploadError != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(_uploadError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Tap untuk coba lagi', style: TextStyle(color: Color(0xFF4A5565), fontSize: 12)),
        ],
      );
    }

    // Belum ada gambar (placeholder)
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6900).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_a_photo, color: Color(0xFFFF6900), size: 36),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tambah Foto Resep',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF364153)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kamera atau Galeri',
          style: TextStyle(color: Color(0xFF4A5565), fontSize: 12),
        ),
      ],
    );
  }
}