import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import 'report_form_screen.dart';
import 'package:intl/intl.dart';
import 'report_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<HazardReport>? _reports;
  bool _isLoading = false;
  final _supabaseService = SupabaseService();
  bool _isSupabaseInitialized = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.mediumAnimation,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.initializeSupabase();
      setState(() {
        _isSupabaseInitialized = true;
      });
      _loadReports();
      _controller.forward();
    } catch (e) {
      debugPrint('Error inisialisasi Supabase: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal inisialisasi Supabase: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
      );
    }
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _supabaseService.getHazardReports();

      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error mengambil laporan: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat laporan: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToDetail(HazardReport report) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                ReportDetailScreen(report: report),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Sumber Bahaya',
          style: AppTheme.headingMd.copyWith(
            color: Colors.white,
            fontWeight: AppTheme.fontWeightBold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReports,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showProcedureInfo,
            tooltip: 'Informasi Prosedur',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: AnimatedGradientButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const ReportFormScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                var begin = const Offset(0.0, 1.0);
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
          _loadReports();
        },
        text: 'Tambah Laporan',
        icon: Icons.add_rounded,
        width: 180,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat laporan...',
              style: AppTheme.bodyLg.copyWith(
                fontWeight: AppTheme.fontWeightMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isSupabaseInitialized) {
      return Center(
        child: FadeSlideTransition(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: AppTheme.textLight),
              const SizedBox(height: 16),
              Text('Gagal terhubung ke Supabase', style: AppTheme.headingMd),
              const SizedBox(height: 8),
              Text(
                'Periksa konfigurasi Supabase Anda',
                style: AppTheme.bodyMd.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              AnimatedGradientButton(
                onPressed: _initializeApp,
                text: 'Coba Lagi',
                icon: Icons.refresh_rounded,
                width: 150,
              ),
            ],
          ),
        ),
      );
    }

    if (_reports == null || _reports!.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 100,
        ),
        itemCount: _reports!.length,
        itemBuilder: (context, index) {
          final report = _reports![index];
          return AnimatedCard(
            height: 120,
            onTap: () => _navigateToDetail(report),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(report.status),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(report.status),
                      color: _getStatusColor(report.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 54,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            report.hazardDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.headingSm.copyWith(
                              fontSize: AppTheme.fontSizeMd - 1,
                            ),
                          ),
                          SizedBox(height: 0.5),
                          Text(
                            '${report.reporterName} - ${report.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodySm.copyWith(
                              fontSize: AppTheme.fontSizeSm - 1,
                            ),
                          ),
                          SizedBox(height: 0.5),
                          Text(
                            _formatDate(report.reportDatetime),
                            style: AppTheme.bodyXs,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTrailingAction(report),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeSlideTransition(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PulseAnimation(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppTheme.accentLight,
              ),
            ),
            const SizedBox(height: 16),
            Text('Belum ada laporan sumber bahaya', style: AppTheme.headingMd),
            const SizedBox(height: 8),
            Text(
              'Klik tombol di bawah untuk membuat laporan baru',
              style: AppTheme.bodySm,
            ),
            const SizedBox(height: 24),
            AnimatedGradientButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportFormScreen(),
                  ),
                );
                _loadReports();
              },
              text: 'Buat Laporan',
              icon: Icons.add_rounded,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingAction(HazardReport report) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'validate':
            await _supabaseService.validateReport(
              report.id!,
              'Admin',
              'Laporan telah divalidasi',
            );
            _loadReports();
            break;
          case 'follow_up':
            await _supabaseService.addFollowUp(
              report.id!,
              'Sedang ditindaklanjuti oleh tim terkait',
              'Admin',
            );
            _loadReports();
            break;
          case 'close':
            await _supabaseService.closeReport(
              report.id!,
              'Admin',
              'Laporan telah ditutup setelah perbaikan',
            );
            _loadReports();
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'validate',
              child: Row(
                children: [
                  Icon(Icons.verified, color: AppTheme.info, size: 20),
                  const SizedBox(width: 8),
                  const Text('Validasi Laporan'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'follow_up',
              child: Row(
                children: [
                  Icon(Icons.engineering, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 8),
                  const Text('Tambah Tindak Lanjut'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'close',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  const Text('Tutup Laporan'),
                ],
              ),
            ),
          ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'submitted':
        return AppTheme.info;
      case 'validated':
        return AppTheme.warning;
      case 'in_progress':
        return AppTheme.accentColor;
      case 'closed':
        return AppTheme.success;
      default:
        return AppTheme.textLight;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'submitted':
        return Icons.assignment_turned_in_rounded;
      case 'validated':
        return Icons.verified_rounded;
      case 'in_progress':
        return Icons.engineering_rounded;
      case 'closed':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void _showProcedureInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi Prosedur LSB'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Aplikasi ini mengimplementasikan:',
                    style: AppTheme.headingSm,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Format Form FM-LSB dari PT Nindya Karya Revisi 0.4',
                    style: AppTheme.bodySm,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Database menggunakan struktur tabel "FM-RLSB (Register LSB) R-0.1"',
                    style: AppTheme.bodySm,
                  ),
                  const SizedBox(height: 16),
                  Text('Fitur Utama:', style: AppTheme.headingSm),
                  const SizedBox(height: 8),
                  Text(
                    '• OCR untuk membaca formulir laporan bahaya',
                    style: AppTheme.bodySm,
                  ),
                  Text(
                    '• Analisis AI untuk mengekstrak data penting',
                    style: AppTheme.bodySm,
                  ),
                  Text(
                    '• Pengelolaan workflow sesuai prosedur PT Nindya Karya',
                    style: AppTheme.bodySm,
                  ),
                  Text(
                    '• Pencatatan dan pelacakan penanganan bahaya',
                    style: AppTheme.bodySm,
                  ),
                  const SizedBox(height: 16),
                  Text('Format Dokumen:', style: AppTheme.headingSm),
                  const SizedBox(height: 8),
                  Text('• No. Dokumen: FM-LSB', style: AppTheme.bodySm),
                  Text('• No. Revisi: 0.4', style: AppTheme.bodySm),
                  Text('• Tgl. Berlaku: 05/07/2022', style: AppTheme.bodySm),
                  const SizedBox(height: 16),
                  Text('Status Koneksi Supabase:', style: AppTheme.headingSm),
                  const SizedBox(height: 8),
                  Text(
                    '• Database: ${_isSupabaseInitialized ? "Terhubung" : "Tidak terhubung"}',
                    style: AppTheme.bodySm.copyWith(
                      color: _isSupabaseInitialized ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '• Storage Bucket: ${_supabaseService.isStorageBucketAvailable ? "Tersedia" : "Tidak tersedia"}',
                    style: AppTheme.bodySm.copyWith(
                      color:
                          _supabaseService.isStorageBucketAvailable
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_supabaseService.isStorageBucketAvailable)
                    Text(
                      'Catatan: Bucket storage belum dibuat. Silakan ikuti petunjuk di file BUCKET_SETUP.md untuk membuat bucket dan mengatur RLS.',
                      style: AppTheme.bodySm.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
