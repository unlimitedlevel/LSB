import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dotted_border/dotted_border.dart'; // Import untuk border putus-putus
import 'package:image_picker/image_picker.dart';
import '../services/report_service.dart';
import '../utils/form_correction_utils.dart';
import 'report_form_screen.dart';
import '../config/app_theme.dart'; // Import AppTheme

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
    if (_isProcessing) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (mounted) {
        setState(() {
          _processingError = null;
          _selectedImage = null;
          _webFileBytes = null;
        });
      }

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _webFileBytes = bytes;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      }

      _processSelectedImage();
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingError = 'Gagal memilih gambar: ${e.toString()}';
          _isProcessing = false;
        });
      }
      debugPrint('Image picking error: $e');
    }
  }

  void _processSelectedImage() async {
    if (!_hasImage()) {
      if (mounted) {
        setState(() {
          _processingError = 'Silakan pilih gambar terlebih dahulu.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _processingError = null;
      });
    }

    try {
      dynamic imageSource = kIsWeb ? _webFileBytes : _selectedImage;

      if (imageSource == null) {
        throw Exception('Sumber gambar tidak valid.');
      }

      final Map<String, dynamic>? extractedData = await _reportService
          .processImage(imageSource);

      if (!mounted) return;

      if (extractedData != null) {
        debugPrint('OCR Extracted Data: $extractedData');

        final metadata = extractedData['metadata'];
        if (metadata is Map &&
            metadata['correction_detected'] == true &&
            metadata['correction_report'] != null) {
          FormCorrectionUtils.showCorrectionReport(
            context,
            metadata['correction_report'].toString(),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReportFormScreen(initialData: extractedData),
          ),
        );
      } else {
        throw Exception('Gagal mengekstrak data dari gambar.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingError = 'Gagal memproses gambar: ${e.toString()}';
          _isProcessing = false;
        });
        debugPrint('Image processing error: $e');
      }
    } finally {
      if (mounted && _isProcessing) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _hasImage() {
    return _selectedImage != null || _webFileBytes != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Gunakan AppBar standar dari tema
      appBar: AppBar(
        title: const Text('Scan Formulir LSB'),
        // backgroundColor: theme.colorScheme.primary, // Hapus agar konsisten
        // foregroundColor: theme.colorScheme.onPrimary, // Hapus agar konsisten
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Sesuaikan padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unggah Foto Formulir LSB', // Judul lebih jelas
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12), // Sedikit lebih banyak spasi
              Text(
                'Pastikan foto formulir terlihat jelas dan tidak buram untuk hasil terbaik.', // Instruksi lebih humanis
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32), // Spasi lebih besar sebelum area gambar

              // Gunakan DottedBorder untuk area pemilihan gambar
              GestureDetector(
                onTap: _isProcessing ? null : _pickImage,
                child: DottedBorder(
                  color: _processingError != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withOpacity(0.6),
                  strokeWidth: 2,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(16),
                  dashPattern: const [8, 6],
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Warna latar belakang lebih lembut
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15), // Cocokkan radius DottedBorder
                    ),
                    child: _getImageWidget(theme), // Panggil widget gambar
                  ),
                ),
              ),
              const SizedBox(height: 24), // Spasi setelah area gambar

              _buildActionButtons(theme), // Panggil widget tombol
              const SizedBox(height: 20), // Spasi sebelum error

              if (_processingError != null) _buildErrorDisplay(theme), // Tampilkan error jika ada
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan konten di dalam area DottedBorder
  Widget _getImageWidget(ThemeData theme) {
    if (_isProcessing) {
      // Tampilan saat sedang memproses
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text('Menganalisis Formulir...', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'AI sedang bekerja, mohon tunggu...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (_selectedImage != null || _webFileBytes != null) {
      // Tampilan preview gambar yang dipilih
      return ClipRRect(
        borderRadius: BorderRadius.circular(15), // Cocokkan radius DottedBorder
        child: kIsWeb
            ? Image.memory(
                _webFileBytes!,
                fit: BoxFit.contain, // Agar gambar tidak terpotong
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorPlaceholder(theme, "Gagal memuat preview"),
              )
            : Image.file(
                _selectedImage!,
                fit: BoxFit.contain, // Agar gambar tidak terpotong
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageErrorPlaceholder(theme, "Gagal memuat preview"),
              ),
      );
    } else {
      // Tampilan placeholder awal
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined, // Ikon lebih relevan
            size: 72, // Lebih besar
            color: theme.colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(height: 20),
          Text(
            'Ketuk di sini untuk Scan',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Ambil foto formulir LSB dari galeri Anda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
  }

  // Widget placeholder jika gambar gagal dimuat
  Widget _buildImageErrorPlaceholder(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol aksi
  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tombol utama untuk memilih/mengganti gambar
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _pickImage,
          icon: Icon(_hasImage() ? Icons.sync_outlined : Icons.photo_library_outlined),
          label: Text(_hasImage() ? 'Ganti Gambar' : 'Pilih dari Galeri'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16), // Lebih tinggi
            textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sesuaikan radius
          ),
        ),
        // Tombol proses hanya muncul jika ada gambar dan tidak sedang memproses
        if (_hasImage() && !_isProcessing) ...[
          const SizedBox(height: 12),
          FilledButton.icon( // Gunakan FilledButton untuk aksi utama setelah gambar dipilih
            onPressed: _processSelectedImage,
            icon: const Icon(Icons.auto_fix_high_outlined), // Ikon AI/proses
            label: const Text('Proses dengan AI'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              backgroundColor: AppTheme.accentColor, // Warna aksen
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  // Widget untuk menampilkan pesan error
  Widget _buildErrorDisplay(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer, // Warna solid dari tema
        borderRadius: BorderRadius.circular(12), // Sesuaikan radius
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded, // Ikon warning
            color: theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _processingError ?? 'Terjadi kesalahan tidak diketahui.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
