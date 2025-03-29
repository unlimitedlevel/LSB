import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/hazard_report.dart';
import '../services/report_service.dart';
import '../services/supabase_service.dart';
import '../widgets/image_input.dart';
import '../widgets/animated_widgets.dart';
import '../utils/app_theme.dart';
import 'success_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reporterNameController = TextEditingController();
  final _reporterPositionController = TextEditingController();
  final _locationController = TextEditingController();
  final _hazardDescriptionController = TextEditingController();
  final _suggestedActionController = TextEditingController();
  final _lsbNumberController = TextEditingController();
  final _reporterSignatureController = TextEditingController();

  DateTime _reportDate = DateTime.now();
  String _observationType = 'Unsafe Condition';
  final List<String> _observationTypes = [
    'Unsafe Condition',
    'Unsafe Action',
    'Intervensi',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  dynamic _selectedImage;
  Uint8List? _imagePreview;
  String? _uploadedImagePath;
  bool _isLoading = false;
  bool _isProcessing = false;
  bool _isManualInput = true;
  bool _isSupabaseInitialized = false;
  final ReportService _reportService = ReportService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _initializeSupabase();

    // Setup animasi
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.mediumAnimation,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  Future<void> _initializeSupabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.initializeSupabase();
      setState(() {
        _isSupabaseInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _reporterNameController.dispose();
    _reporterPositionController.dispose();
    _locationController.dispose();
    _hazardDescriptionController.dispose();
    _suggestedActionController.dispose();
    _lsbNumberController.dispose();
    _reporterSignatureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectImage(dynamic image) async {
    setState(() {
      _selectedImage = image;
      _isProcessing = true;
    });

    if (image != null) {
      // Tampilkan preview gambar
      if (image is XFile) {
        _imagePreview = await image.readAsBytes();
      } else if (image is File) {
        _imagePreview = await image.readAsBytes();
      }

      // Proses gambar dengan OCR dan analisis
      final extractedReport = await _reportService.processHazardReportImage(
        _selectedImage,
      );

      if (extractedReport != null) {
        // Upload gambar dan dapatkan URL
        if (_imagePreview != null) {
          try {
            final filename =
                'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            _uploadedImagePath = await _supabaseService.uploadImage(
              _imagePreview!,
              filename,
            );

            if (_uploadedImagePath == null) {
              // Jika gagal upload, tampilkan pesan tetapi tetap lanjutkan
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Gagal mengupload gambar, tetapi data tetap diproses',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error upload gambar: $e');
            // Error upload gambar tidak fatal, tetap lanjutkan proses
          }
        }

        // Isi form dengan hasil ekstraksi
        setState(() {
          _reporterNameController.text = extractedReport.reporterName;
          _reporterPositionController.text = extractedReport.reporterPosition;
          _locationController.text = extractedReport.location;
          _reportDate = extractedReport.reportDatetime;
          _observationType = extractedReport.observationType;
          _hazardDescriptionController.text = extractedReport.hazardDescription;
          _suggestedActionController.text = extractedReport.suggestedAction;
          _lsbNumberController.text = extractedReport.lsbNumber ?? '';
          _reporterSignatureController.text =
              extractedReport.reporterSignature ?? '';
          _isManualInput = true;
          _isProcessing = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal mengekstrak informasi dari gambar'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final report = HazardReport(
        reporterName: _reporterNameController.text,
        reporterPosition: _reporterPositionController.text,
        location: _locationController.text,
        reportDatetime: _reportDate,
        observationType: _observationType,
        hazardDescription: _hazardDescriptionController.text,
        suggestedAction: _suggestedActionController.text,
        lsbNumber:
            _lsbNumberController.text.isEmpty
                ? null
                : _lsbNumberController.text,
        reporterSignature:
            _reporterSignatureController.text.isEmpty
                ? null
                : _reporterSignatureController.text,
        imagePath: _uploadedImagePath,
      );

      // Kirim laporan ke Supabase
      HazardReport? submittedReport;
      try {
        if (_isSupabaseInitialized) {
          submittedReport = await _supabaseService.submitHazardReport(report);
        } else {
          submittedReport = await _reportService.submitManualReport(report);
        }

        setState(() {
          _isLoading = false;
        });

        if (submittedReport != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      SuccessScreen(report: submittedReport!),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                var begin = const Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.easeInOutCubic;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal mengirim laporan. Silakan coba lagi.'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error saat submit laporan: $e');
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Laporan Sumber Bahaya',
          style: AppTheme.headingMd.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memproses...',
                      style: AppTheme.bodyLg.copyWith(
                        fontWeight: AppTheme.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedCard(
                          height: 180,
                          child:
                              _imagePreview != null
                                  ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Hero(
                                        tag: 'selected_image',
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadiusMedium,
                                          ),
                                          child: Image.memory(
                                            _imagePreview!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Material(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadiusSmall,
                                          ),
                                          elevation: 3,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.refresh,
                                              color: AppTheme.primaryColor,
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                builder:
                                                    (ctx) => Container(
                                                      height:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          0.4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    20,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            blurRadius: 10,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  -5,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 20,
                                                          ),
                                                      child: ImageInput(
                                                        onImageSelected:
                                                            _selectImage,
                                                      ),
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PulseAnimation(
                                          child: Icon(
                                            Icons.cloud_upload_rounded,
                                            size: 40,
                                            color: AppTheme.primaryLight,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Pilih gambar LSB untuk diproses',
                                          style: AppTheme.bodyMd.copyWith(
                                            fontWeight:
                                                AppTheme.fontWeightMedium,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedGradientButton(
                                          onPressed:
                                              _isProcessing
                                                  ? () {}
                                                  : () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      builder:
                                                          (ctx) => Container(
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  const BorderRadius.only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                          20,
                                                                        ),
                                                                    topRight:
                                                                        Radius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  blurRadius:
                                                                      10,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        -5,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 20,
                                                                ),
                                                            child: ImageInput(
                                                              onImageSelected:
                                                                  _selectImage,
                                                            ),
                                                          ),
                                                    );
                                                  },
                                          text: 'Pilih Gambar',
                                          icon: Icons.photo_library_rounded,
                                          isLoading: _isProcessing,
                                          width: 180,
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 24),
                        FadeSlideTransition(
                          beginOffset: const Offset(0, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Pelapor',
                                style: AppTheme.headingMd,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryBackground,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusMedium,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _reporterNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama Pelapor',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama pelapor wajib diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _reporterPositionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Posisi / Jabatan',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.work),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Posisi/jabatan wajib diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeSlideTransition(
                          beginOffset: const Offset(0, 30),
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detail Laporan', style: AppTheme.headingMd),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryBackground,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusMedium,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _locationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Lokasi Kejadian',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.location_on),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Lokasi wajib diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _reportDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary:
                                                      AppTheme.primaryColor,
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface:
                                                      AppTheme.textPrimary,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _reportDate = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.borderRadiusMedium,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tanggal Laporan',
                                                  style: AppTheme.labelMd,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_reportDate.day} ${_getMonthName(_reportDate.month)} ${_reportDate.year}',
                                                  style: AppTheme.bodyMd.copyWith(
                                                    fontWeight:
                                                        AppTheme
                                                            .fontWeightMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadiusMedium,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Jenis Pengamatan',
                                          border: InputBorder.none,
                                          icon: Icon(
                                            Icons.visibility,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        value: _observationType,
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _observationType = value;
                                            });
                                          }
                                        },
                                        items:
                                            _observationTypes.map((type) {
                                              return DropdownMenuItem<String>(
                                                value: type,
                                                child: Text(
                                                  type,
                                                  style: AppTheme.bodyMd,
                                                ),
                                              );
                                            }).toList(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Pilih jenis pengamatan';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _hazardDescriptionController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        labelText: 'Uraian Bahaya',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.warning_amber_rounded,
                                        ),
                                        alignLabelWithHint: true,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Uraian bahaya wajib diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _suggestedActionController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        labelText: 'Tindakan/Saran Perbaikan',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.build),
                                        alignLabelWithHint: true,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Tindakan perbaikan wajib diisi';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _lsbNumberController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nomor LSB (Opsional)',
                                        hintText: 'Sesuai format FM-RLSB R-0.1',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _reporterSignatureController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama Penandatangan',
                                        hintText:
                                            'Nama yang tertera pada tanda tangan pelapor',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.edit),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        FadeSlideTransition(
                          beginOffset: const Offset(0, 40),
                          duration: const Duration(milliseconds: 700),
                          child: AnimatedGradientButton(
                            onPressed: _submitReport,
                            text: 'Kirim Laporan',
                            icon: Icons.send_rounded,
                            height: 56,
                            isLoading: _isLoading,
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
