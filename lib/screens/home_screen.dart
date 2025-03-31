import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import 'report_form_screen.dart';
import 'package:intl/intl.dart';
import 'report_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HazardReport>> _reportsFuture;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isSupabaseInitialized = false;
  bool _isTableCreated = false;
  String _tableCreationMessage = '';

  @override
  void initState() {
    super.initState();
    _reportsFuture = Future.value([]);
    _checkSupabaseInitialization();

    // Tambahkan listener untuk auto refresh saat fokus kembali ke halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusNode = FocusNode();
      FocusScope.of(context).requestFocus(focusNode);
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _loadReports();
        }
      });
    });
  }

  void _checkSupabaseInitialization() {
    try {
      Supabase.instance.client;
      setState(() {
        _isSupabaseInitialized = true;
      });

      _createTableIfNeeded();
      _loadReports();
    } catch (e) {
      setState(() {
        _isSupabaseInitialized = false;
        _reportsFuture = Future.value([]);
      });
      debugPrint('Supabase not initialized: $e');
    }
  }

  Future<void> _createTableIfNeeded() async {
    if (!_isSupabaseInitialized) return;

    try {
      final tableExists = await _supabaseService.createTableIfNotExists();

      setState(() {
        _isTableCreated = tableExists;
        _tableCreationMessage =
            tableExists
                ? 'Tabel hazard_reports siap digunakan'
                : 'Tabel hazard_reports tidak ditemukan. Silakan buat tabel secara manual di Supabase Dashboard';
      });
    } catch (e) {
      setState(() {
        _isTableCreated = false;
        _tableCreationMessage = 'Gagal memeriksa tabel: $e';
      });
      debugPrint('Error checking table: $e');
    }
  }

  void _loadReports() {
    if (_isSupabaseInitialized) {
      _reportsFuture = _supabaseService.getHazardReports();
    } else {
      _reportsFuture = Future.value([]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Sumber Bahaya (LSB)')),
      body: _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          ).then((_) {
            setState(() {
              _loadReports();
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadReports();
        });
      },
      child: Column(
        children: [
          if (!_isSupabaseInitialized)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.yellow.shade100,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade800),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Aplikasi berjalan dalam mode demo. Konfigurasi Supabase pada file .env untuk menggunakan semua fitur.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          if (kIsWeb)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Icon(Icons.web, color: Colors.blue.shade800),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Aplikasi berjalan pada browser web. Beberapa fitur seperti kamera mungkin terbatas.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          if (_isSupabaseInitialized)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade800),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Terhubung dengan Supabase, mode aplikasi penuh aktif.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (_tableCreationMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 36),
                      child: Text(
                        _tableCreationMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _isTableCreated
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<HazardReport>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint('Error in FutureBuilder: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada laporan. \nKlik tombol + untuk menambahkan laporan baru.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else {
                  final reports = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportCard(report);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(HazardReport report) {
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
    final formattedDate =
        report.reportDatetime != null
            ? dateFormatter.format(report.reportDatetime!)
            : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigasi ke detail report
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gambar
            if (report.imagePath != null && report.imagePath!.isNotEmpty)
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  report.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi dan tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report.location ?? 'Lokasi tidak tersedia',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reporter
                  if (report.reporterName != null)
                    Text(
                      'Dilaporkan oleh: ${report.reporterName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Observation Type
                  if (report.observationType != null)
                    Chip(
                      label: Text(
                        report.observationType!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  const SizedBox(height: 12),

                  // Deskripsi Hazard
                  if (report.hazardDescription != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Bahaya:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.hazardDescription!,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Status Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nomor LSB jika ada
                      if (report.lsbNumber != null &&
                          report.lsbNumber!.isNotEmpty)
                        Text(
                          'No. LSB: ${report.lsbNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const SizedBox(),

                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: report.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.statusTranslated,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
