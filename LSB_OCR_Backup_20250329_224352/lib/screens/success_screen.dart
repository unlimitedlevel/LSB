import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hazard_report.dart';
import 'home_screen.dart';

class SuccessScreen extends StatefulWidget {
  final HazardReport report;

  const SuccessScreen({super.key, required this.report});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSupabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkSupabaseInitialization();
  }

  void _checkSupabaseInitialization() {
    try {
      // Coba akses instance Supabase, jika tidak ada exception, berarti Supabase sudah diinisialisasi
      Supabase.instance.client;
      setState(() {
        _isSupabaseInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isSupabaseInitialized = false;
      });
      debugPrint('Supabase not initialized: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Berhasil Dibuat'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Laporan Berhasil Terkirim!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (_isSupabaseInitialized)
              const Text(
                'Laporan sumber bahaya Anda telah berhasil disimpan dalam sistem. Terima kasih atas kontribusi Anda untuk meningkatkan keselamatan kerja.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade700),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Mode Demo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aplikasi berjalan dalam mode demo, laporan tidak disimpan ke database. Konfigurasi Supabase untuk penggunaan sebenarnya.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Detail Laporan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nama Pelapor', widget.report.reporterName),
                    _buildInfoRow(
                      'Posisi / Jabatan',
                      widget.report.reporterPosition,
                    ),
                    _buildInfoRow('Lokasi Kejadian', widget.report.location),
                    _buildInfoRow(
                      'Tanggal / Waktu',
                      DateFormat(
                        'dd MMMM yyyy, HH:mm',
                      ).format(widget.report.reportDatetime),
                    ),
                    _buildInfoRow(
                      'Jenis Pengamatan',
                      widget.report.observationType,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uraian Pengamatan Bahaya:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(widget.report.hazardDescription),
                    ),
                    const Text(
                      'Tindakan Intervensi / Saran Perbaikan:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.report.suggestedAction),
                    if (widget.report.lsbNumber != null &&
                        widget.report.lsbNumber!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Nomor LSB:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.report.lsbNumber!),
                    ],
                    if (widget.report.reporterSignature != null &&
                        widget.report.reporterSignature!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Ditandatangani oleh:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.report.reporterSignature!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sesuai Format:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'FM-LSB (No. Dokumen) - PT Nindya Karya',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Revisi 0.4, Berlaku: 05/07/2022',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Register: FM-RLSB (Register LSB) R-0.1',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Kembali ke Halaman Utama'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
