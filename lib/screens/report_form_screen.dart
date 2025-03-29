import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import '../services/report_service.dart';
import '../config/app_theme.dart';
import 'success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reporterNameController = TextEditingController();
  final _reporterPositionController = TextEditingController();
  final _locationController = TextEditingController();
  final _hazardDescriptionController = TextEditingController();
  final _suggestedActionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isProcessing = false;
  bool _isLoading = false;
  final SupabaseService _supabaseService = SupabaseService();
  final ReportService _reportService = ReportService();

  // Status untuk proses OCR
  bool _isOcrRunning = false;
  String? _ocrErrorMessage;
  Map<String, dynamic>? _extractedData;

  @override
  void dispose() {
    _reporterNameController.dispose();
    _reporterPositionController.dispose();
    _locationController.dispose();
    _hazardDescriptionController.dispose();
    _suggestedActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan Bahaya')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Upload Gambar
                _buildImageSection(),
                const SizedBox(height: 24),

                // Form Laporan Bahaya
                _buildReportForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
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
          onTap: _isProcessing ? null : _selectImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child:
                _isProcessing
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
                onPressed: _isProcessing ? null : _selectImage,
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
                onPressed: _isProcessing ? null : _removeImage,
                icon: const Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Hapus Gambar',
              ),
            ],
          ],
        ),

        // Pesan kesalahan OCR jika ada
        if (_ocrErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _ocrErrorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),

        // Tampilkan pesan jika koreksi terdeteksi
        if (_extractedData != null &&
            _extractedData!['metadata'] != null &&
            _extractedData!['metadata']['correction_detected'] == true)
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

  Widget _buildReportForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Laporan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Nama Pelapor
        TextFormField(
          controller: _reporterNameController,
          decoration: const InputDecoration(
            labelText: 'Nama Pelapor',
            hintText: 'Masukkan nama pelapor',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama pelapor harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Jabatan Pelapor
        TextFormField(
          controller: _reporterPositionController,
          decoration: const InputDecoration(
            labelText: 'Jabatan/Posisi',
            hintText: 'Masukkan jabatan atau posisi pelapor',
            prefixIcon: Icon(Icons.work),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jabatan/posisi harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Lokasi Bahaya
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Lokasi Bahaya',
            hintText: 'Masukkan lokasi bahaya dengan spesifik',
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lokasi bahaya harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Tanggal Laporan
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Laporan',
              hintText: 'Pilih tanggal laporan',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Deskripsi Bahaya
        TextFormField(
          controller: _hazardDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Deskripsi Bahaya',
            hintText: 'Jelaskan kondisi bahaya secara detail',
            prefixIcon: Icon(Icons.warning),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi bahaya harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Saran Tindakan
        TextFormField(
          controller: _suggestedActionController,
          decoration: const InputDecoration(
            labelText: 'Saran Tindakan',
            hintText: 'Berikan saran tindakan untuk mengatasi bahaya',
            prefixIcon: Icon(Icons.build),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Saran tindakan harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),

        // Tombol Submit
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'KIRIM LAPORAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _getImageWidget() {
    if (_selectedImage != null) {
      // Untuk platform mobile
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_webImage != null) {
      // Untuk platform web
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _webImage!,
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
    return _selectedImage != null || _webImage != null;
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      setState(() {
        _isProcessing = true;
        _ocrErrorMessage = null;
      });

      if (kIsWeb) {
        // Untuk platform web
        _webImage = await pickedImage.readAsBytes();
      } else {
        // Untuk platform mobile
        _selectedImage = File(pickedImage.path);
      }

      // Proses OCR gambar
      await _processImage();
    } catch (e) {
      debugPrint('Error selecting image: $e');
      setState(() {
        _ocrErrorMessage = 'Gagal memilih gambar: $e';
        _isProcessing = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _extractedData = null;
      _ocrErrorMessage = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _processImage() async {
    try {
      setState(() {
        _isOcrRunning = true;
      });

      // Gunakan ReportService untuk memproses gambar
      dynamic imageSource = kIsWeb ? _webImage : _selectedImage;
      final result = await _reportService.processImage(imageSource);

      if (result != null) {
        setState(() {
          _extractedData = result;

          // Isi form dengan data yang diekstrak
          if (result['reporter_name'] != null) {
            _reporterNameController.text = result['reporter_name'];
          }

          if (result['reporter_position'] != null) {
            _reporterPositionController.text = result['reporter_position'];
          }

          if (result['location'] != null) {
            _locationController.text = result['location'];
          }

          if (result['report_date'] != null) {
            try {
              _selectedDate = DateTime.parse(result['report_date']);
            } catch (e) {
              debugPrint('Error parsing date: $e');
            }
          }

          if (result['hazard_description'] != null) {
            _hazardDescriptionController.text = result['hazard_description'];
          }

          if (result['suggested_action'] != null) {
            _suggestedActionController.text = result['suggested_action'];
          }
        });

        // Tampilkan dialog jika ada koreksi signifikan
        if (result['metadata'] != null &&
            result['metadata']['correction_detected'] == true &&
            result['metadata']['correction_report'] != null) {
          if (mounted) {
            _showCorrectionReport(result['metadata']['correction_report']);
          }
        }
      } else {
        setState(() {
          _ocrErrorMessage = 'Gagal mengekstrak data dari gambar';
        });
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      setState(() {
        _ocrErrorMessage = 'Gagal memproses gambar: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
        _isOcrRunning = false;
      });
    }
  }

  void _showCorrectionReport(String correctionReport) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Text('Perbaikan Teks Otomatis'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sistem telah mendeteksi dan memperbaiki beberapa teks:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(correctionReport),
                const SizedBox(height: 16),
                const Text(
                  'Silakan periksa data di form untuk memastikan kebenaran.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('MENGERTI'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Membuat objek metadata
        Map<String, dynamic> metadata = {};
        if (_extractedData != null && _extractedData!['metadata'] != null) {
          metadata = _extractedData!['metadata'];
        }

        final report = HazardReport(
          reporterName: _reporterNameController.text,
          reporterPosition: _reporterPositionController.text,
          location: _locationController.text,
          reportDate: _selectedDate,
          hazardDescription: _hazardDescriptionController.text,
          suggestedAction: _suggestedActionController.text,
          status: 'open',
          metadata: metadata,
          createdAt: DateTime.now(),
        );

        String? imageUrl;

        // Upload gambar jika ada
        if (_hasImage()) {
          imageUrl = await _uploadImage();
        }

        // Update URL gambar jika berhasil diupload
        final updatedReport = report.copyWith(imageUrl: imageUrl);

        // Simpan laporan ke Supabase
        final savedReport = await _supabaseService.saveHazardReport(
          updatedReport,
        );

        // Reset loading state
        setState(() {
          _isLoading = false;
        });

        if (savedReport != null) {
          // Navigasi ke halaman sukses
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(report: savedReport),
            ),
          );
        } else {
          // Tampilkan error jika gagal menyimpan
          _showErrorDialog('Gagal menyimpan laporan. Silakan coba lagi nanti.');
        }
      } catch (e) {
        debugPrint('Error submitting report: $e');
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final String fileName = 'hazard_${const Uuid().v4()}.jpg';
      final String filePath = 'hazard-images/$fileName';

      if (kIsWeb && _webImage != null) {
        // Upload untuk web
        await Supabase.instance.client.storage
            .from('hazard-images')
            .uploadBinary(
              filePath,
              _webImage!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        return _supabaseService.getImageUploadUrl(filePath);
      } else if (_selectedImage != null) {
        // Upload untuk mobile
        await Supabase.instance.client.storage
            .from('hazard-images')
            .upload(
              filePath,
              _selectedImage!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        return _supabaseService.getImageUploadUrl(filePath);
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
