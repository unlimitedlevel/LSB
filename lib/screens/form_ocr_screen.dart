import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:lsb_ocr/services/report_service.dart';
import 'package:lsb_ocr/utils/form_correction_utils.dart';
import 'package:lsb_ocr/screens/report_form_screen.dart';
import 'package:lsb_ocr/config/app_theme.dart';

class FormOCRScreen extends StatefulWidget {
  const FormOCRScreen({super.key});

  @override
  State<FormOCRScreen> createState() => _FormOCRScreenState();
}

class _FormOCRScreenState extends State<FormOCRScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webFileBytes;
  bool _isProcessing = false;
  String? _processingError;
  final ReportService _reportService = ReportService();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _processingError = null;
      });

      if (kIsWeb) {
        // Untuk platform web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webFileBytes = bytes;
        });
      } else {
        // Untuk platform mobile
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }

      // Otomatis proses gambar setelah dipilih
      _processSelectedImage();
    } catch (e) {
      setState(() {
        _processingError = 'Gagal memilih gambar: ${e.toString()}';
      });
    }
  }

  void _processSelectedImage() async {
    setState(() {
      _isProcessing = true;
      _processingError = null;
    });

    try {
      dynamic imageSource;

      if (kIsWeb) {
        imageSource = _webFileBytes;
      } else {
        imageSource = _selectedImage;
      }

      if (imageSource == null) {
        throw Exception('Silakan pilih gambar terlebih dahulu');
      }

      final extractedData = await _reportService.processImage(imageSource);

      if (!mounted) return;

      if (extractedData != null) {
        // Cek apakah ada koreksi teks yang dilakukan
        if (extractedData['metadata'] != null &&
            extractedData['metadata']['correction_detected'] == true &&
            extractedData['metadata']['correction_report'] != null) {
          // Tampilkan dialog koreksi jika ada
          FormCorrectionUtils.showCorrectionReport(
            context,
            extractedData['metadata']['correction_report'].toString(),
          );
        }

        // Navigasi ke form dengan data yang sudah diisi
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportFormScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingError = e.toString();
          _isProcessing = false;
        });

        // Tampilkan error dalam dialog
        FormCorrectionUtils.showErrorDialog(
          context,
          'Gagal memproses gambar: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan LSB Form'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unggah Foto Laporan LSB',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih foto dari galeri yang menampilkan formulir LSB dengan jelas',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Area pilih gambar
              GestureDetector(
                onTap: _isProcessing ? null : _pickImage,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _getImageWidget(),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickImage,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        _hasImage() ? 'Ganti Gambar' : 'Pilih Gambar',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_hasImage()) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processSelectedImage,
                      icon: const Icon(Icons.document_scanner),
                      label: const Text('Proses Ulang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),

              // Menampilkan pesan error jika ada
              if (_processingError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terjadi Kesalahan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _processingError!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memproses gambar...', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    } else if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_webFileBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _webFileBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Ketuk untuk memilih gambar',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Format: JPG, PNG',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      );
    }
  }

  bool _hasImage() {
    return _selectedImage != null || _webFileBytes != null;
  }
}
