import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import '../services/report_service.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/report_form_widget.dart';
import '../utils/form_correction_utils.dart';
import 'success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

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
  final _lsbNumberController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isProcessing = false;
  bool _isLoading = false;
  final SupabaseService _supabaseService = SupabaseService();
  final ReportService _reportService = ReportService();

  // Status untuk proses OCR
  String? _ocrErrorMessage;
  Map<String, dynamic>? _extractedData;

  String _selectedObservationType = 'Unsafe Condition';

  @override
  void dispose() {
    _reporterNameController.dispose();
    _reporterPositionController.dispose();
    _locationController.dispose();
    _hazardDescriptionController.dispose();
    _suggestedActionController.dispose();
    _lsbNumberController.dispose();
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
                ImagePickerWidget(
                  isProcessing: _isProcessing,
                  selectedImage: _selectedImage,
                  webImage: _webImage,
                  onImageSelected:
                      (file) => setState(() {
                        _selectedImage = file;
                        if (file != null) {
                          _processImage();
                        }
                      }),
                  onWebImageSelected:
                      (bytes) => setState(() {
                        _webImage = bytes;
                        if (bytes != null) {
                          _processImage();
                        }
                      }),
                  onProcessStart:
                      () => setState(() {
                        _isProcessing = true;
                        _ocrErrorMessage = null;
                      }),
                  onProcessEnd:
                      () => setState(() {
                        _isProcessing = false;
                      }),
                  errorMessage: _ocrErrorMessage,
                  extractedData: _extractedData,
                ),
                const SizedBox(height: 24),

                // Form Laporan Bahaya
                ReportFormWidget(
                  reporterNameController: _reporterNameController,
                  reporterPositionController: _reporterPositionController,
                  locationController: _locationController,
                  hazardDescriptionController: _hazardDescriptionController,
                  suggestedActionController: _suggestedActionController,
                  lsbNumberController: _lsbNumberController,
                  selectedDate: _selectedDate,
                  selectedObservationType: _selectedObservationType,
                  onDateSelected:
                      (date) => setState(() {
                        _selectedDate = date;
                      }),
                  onObservationTypeChanged:
                      (type) => setState(() {
                        _selectedObservationType = type;
                      }),
                  onSubmit: _submitReport,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processImage() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      // Gunakan ReportService untuk memproses gambar
      dynamic imageSource = kIsWeb ? _webImage : _selectedImage;
      final result = await _reportService.processImage(imageSource);

      if (!mounted) return;

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

          if (result['observation_type'] != null) {
            final observationType = result['observation_type'];
            if ([
              'Unsafe Condition',
              'Unsafe Action',
              'Intervensi',
            ].contains(observationType)) {
              _selectedObservationType = observationType;
            }
          }

          if (result['hazard_description'] != null) {
            _hazardDescriptionController.text = result['hazard_description'];
          }

          if (result['suggested_action'] != null) {
            _suggestedActionController.text = result['suggested_action'];
          }

          // Deteksi nomor LSB jika ada
          if (result['lsb_number'] != null) {
            _lsbNumberController.text = result['lsb_number'];
          }
        });

        // Tampilkan dialog jika ada koreksi signifikan
        if (result['metadata'] != null &&
            result['metadata']['correction_detected'] == true &&
            result['metadata']['correction_report'] != null) {
          if (mounted) {
            var corrReport = result['metadata']['correction_report'];
            String correctionReportText = corrReport.toString();
            FormCorrectionUtils.showCorrectionReport(
              context,
              correctionReportText,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ocrErrorMessage = e.toString();
        });
        FormCorrectionUtils.showErrorDialog(
          context,
          'Terjadi kesalahan saat memproses gambar: $e',
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

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final report = HazardReport(
          reporterName: _reporterNameController.text,
          reporterPosition: _reporterPositionController.text,
          location: _locationController.text,
          reportDatetime: _selectedDate,
          observationType: _selectedObservationType,
          hazardDescription: _hazardDescriptionController.text,
          suggestedAction: _suggestedActionController.text,
          lsbNumber:
              _lsbNumberController.text.isEmpty
                  ? null
                  : _lsbNumberController.text,
          status: 'submitted', // Status default untuk laporan baru
        );

        String? imagePath;

        // Upload gambar jika ada
        if (_selectedImage != null || _webImage != null) {
          imagePath = await _uploadImage();
        }

        // Update URL gambar jika berhasil diupload
        final updatedReport = report.copyWith(imagePath: imagePath);

        // Simpan laporan ke Supabase
        final savedReportMap = await _supabaseService.saveHazardReport(
          updatedReport,
        );

        // Reset loading state
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Konversi dari Map ke HazardReport
        final savedReport = HazardReport.fromJson(savedReportMap);

        // Navigasi ke halaman sukses
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(report: savedReport),
          ),
        );
      } catch (e) {
        debugPrint('Error submitting report: $e');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        FormCorrectionUtils.showErrorDialog(context, 'Terjadi kesalahan: $e');
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
}
