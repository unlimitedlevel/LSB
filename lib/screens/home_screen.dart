import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import 'report_form_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
        _reportsFuture = Future.value(_supabaseService.getDummyReports());
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
      _reportsFuture = Future.value(_supabaseService.getDummyReports());
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
        report.reportDate != null
            ? dateFormatter.format(report.reportDate!)
            : 'Tanggal tidak tersedia';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi ke halaman detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        report.imageUrl != null && report.imageUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                report.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 30,
                                    color: Colors.blue.shade300,
                                  );
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.image_outlined,
                              size: 30,
                              color: Colors.blue.shade300,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.location ?? 'Lokasi tidak tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            text: 'Dilaporkan oleh: ',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: report.reporterName ?? 'Tidak tersedia',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          report.status == 'completed'
                              ? Colors.green.shade100
                              : report.status == 'in_progress'
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status == 'completed'
                          ? 'Selesai'
                          : report.status == 'in_progress'
                          ? 'Proses'
                          : 'Open',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            report.status == 'completed'
                                ? Colors.green.shade800
                                : report.status == 'in_progress'
                                ? Colors.orange.shade800
                                : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text(
                'Deskripsi Bahaya:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                report.hazardDescription ?? 'Tidak ada deskripsi',
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                'Tindakan yang Disarankan:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                report.suggestedAction ?? 'Tidak ada saran tindakan',
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
