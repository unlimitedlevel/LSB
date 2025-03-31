import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../config/app_theme.dart';

class ImagePickerWidget extends StatefulWidget {
  final bool isProcessing;
  final File? selectedImage;
  final Uint8List? webImage;
  final Function(File?) onImageSelected;
  final Function(Uint8List?) onWebImageSelected;
  final Function() onProcessStart;
  final Function() onProcessEnd;
  final String? errorMessage;
  final Map<String, dynamic>? extractedData;

  const ImagePickerWidget({
    super.key,
    required this.isProcessing,
    this.selectedImage,
    this.webImage,
    required this.onImageSelected,
    required this.onWebImageSelected,
    required this.onProcessStart,
    required this.onProcessEnd,
    this.errorMessage,
    this.extractedData,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Sumber Bahaya',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Unggah foto yang menunjukkan sumber bahaya dengan jelas',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Container Image Picker
        InkWell(
          onTap: widget.isProcessing ? null : _selectImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child:
                widget.isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : _getImageWidget(),
          ),
        ),

        const SizedBox(height: 16),

        // Tombol untuk memilih gambar
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.isProcessing ? null : _selectImage,
                icon: const Icon(Icons.add_a_photo),
                label: Text(_hasImage() ? 'Ganti Foto' : 'Pilih Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_hasImage()) ...[
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.isProcessing ? null : _removeImage,
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Hapus Gambar',
              ),
            ],
          ],
        ),

        // Pesan kesalahan OCR jika ada
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),

        // Tampilkan pesan jika koreksi terdeteksi
        if (widget.extractedData != null &&
            widget.extractedData!['metadata'] != null &&
            widget.extractedData!['metadata']['correction_detected'] == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade700),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.yellow.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Beberapa teks telah diperbaiki secara otomatis. Silakan cek data yang diisi.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _getImageWidget() {
    if (widget.selectedImage != null) {
      // Untuk platform mobile
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          widget.selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (widget.webImage != null) {
      // Untuk platform web
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          widget.webImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else {
      // Placeholder ketika belum ada gambar
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk untuk memilih gambar',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      );
    }
  }

  bool _hasImage() {
    return widget.selectedImage != null || widget.webImage != null;
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      widget.onProcessStart();

      if (kIsWeb) {
        // Untuk platform web
        final webImage = await pickedImage.readAsBytes();
        widget.onWebImageSelected(webImage);
      } else {
        // Untuk platform mobile
        widget.onImageSelected(File(pickedImage.path));
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      widget.onProcessEnd();
    }
  }

  void _removeImage() {
    widget.onImageSelected(null);
    widget.onWebImageSelected(null);
  }
}
