import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';

class SuccessScreen extends StatelessWidget {
  final HazardReport report;

  const SuccessScreen({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    final formattedDate =
        report.reportDatetime != null
            ? dateFormatter.format(report.reportDatetime!)
            : 'Tanggal tidak tersedia';

    return WillPopScope(
      onWillPop: () async {
        _navigateToHome(context);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        _buildSuccessIcon(),
                        const SizedBox(height: 24),
                        _buildSuccessTitle(),
                        const SizedBox(height: 16),
                        _buildSuccessMessage(),
                        const SizedBox(height: 32),
                        _buildDivider(),
                        const SizedBox(height: 32),
                        _buildReportDetails(formattedDate),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_circle, size: 80, color: Colors.green.shade500),
    );
  }

  Widget _buildSuccessTitle() {
    return const Text(
      'Laporan Terkirim!',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSuccessMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'Terima kasih atas kontribusi Anda dalam menciptakan lingkungan kerja yang lebih aman. Laporan Anda telah terkirim dan akan segera ditindaklanjuti.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 1, height: 1);
  }

  Widget _buildReportDetails(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Laporan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          icon: Icons.location_on,
          title: 'Lokasi',
          content: report.location ?? 'Tidak tersedia',
        ),
        _buildDetailItem(
          icon: Icons.calendar_today,
          title: 'Tanggal',
          content: formattedDate,
        ),
        _buildDetailItem(
          icon: Icons.warning,
          title: 'Deskripsi Bahaya',
          content: report.hazardDescription ?? 'Tidak tersedia',
        ),
        _buildDetailItem(
          icon: Icons.build,
          title: 'Saran Tindakan',
          content: report.suggestedAction ?? 'Tidak tersedia',
        ),
        _buildDetailItem(
          icon: Icons.person,
          title: 'Dilaporkan oleh',
          content: report.reporterName ?? 'Tidak tersedia',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'Jenis Pengamatan:',
          report.observationType ?? 'Unsafe Condition',
        ),
        if (report.lsbNumber != null && report.lsbNumber!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow('Nomor LSB:', report.lsbNumber!),
        ],
        const SizedBox(height: 16),
        const Text(
          'Detail Bahaya:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToHome(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'KEMBALI KE BERANDA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  Widget _buildDetailRow(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(content, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
