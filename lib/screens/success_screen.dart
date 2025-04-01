import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import 'package:lottie/lottie.dart'; // Import Lottie jika ingin menggunakan animasi
import '../config/app_theme.dart';

class SuccessScreen extends StatelessWidget {
  final HazardReport report;

  const SuccessScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID'); // Format tanggal lebih lengkap
    final formattedDate =
        report.reportDatetime != null
            ? dateFormatter.format(report.reportDatetime!)
            : 'Tanggal tidak tersedia';

    return PopScope(
      canPop: false, // Cegah kembali ke form
      onPopInvoked: (bool didPop) { // Gunakan onPopInvoked
        if (!didPop) {
          _navigateToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface, // Warna background konsisten
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // Sesuaikan padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32), // Spasi atas
                        _buildSuccessIcon(theme), // Kirim tema
                        const SizedBox(height: 28),
                        _buildSuccessTitle(theme), // Kirim tema
                        const SizedBox(height: 12),
                        _buildSuccessMessage(theme), // Kirim tema
                        const SizedBox(height: 40),
                        _buildReportDetailsCard(theme, formattedDate), // Bungkus detail dalam Card
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(context, theme), // Kirim tema
            ],
          ),
        ),
      ),
    );
  }

  // Icon sukses yang lebih modern (bisa pakai Lottie jika ditambahkan)
  Widget _buildSuccessIcon(ThemeData theme) {
    // Contoh jika pakai Lottie (perlu tambahkan lottie: ^3.1.0 di pubspec.yaml dan file aset)
    // return Lottie.asset('assets/animations/success_check.json', width: 150, height: 150, repeat: false);

    // Alternatif dengan Icon
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1), // Warna lebih lembut
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle_outline_rounded, // Ikon outline
        size: 80,
        color: Colors.green.shade600, // Warna ikon lebih solid
      ),
    );
  }

  // Judul sukses dengan style tema
  Widget _buildSuccessTitle(ThemeData theme) {
    return Text(
      'Laporan Terkirim!',
      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  // Pesan sukses dengan style tema
  Widget _buildSuccessMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal
      child: Text(
        'Terima kasih! Laporan Anda telah berhasil dikirim dan akan segera ditinjau.', // Pesan lebih singkat
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant, // Warna teks sesuai tema
          height: 1.4,
        ),
      ),
    );
  }

  // Widget untuk menampilkan detail dalam Card
  Widget _buildReportDetailsCard(ThemeData theme, String formattedDate) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLowest, // Warna card
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Laporan',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24, thickness: 0.5), // Pemisah
            _buildDetailItem(
              theme: theme,
              icon: Icons.location_on_outlined,
              title: 'Lokasi',
              content: report.location ?? 'Tidak tersedia',
            ),
            _buildDetailItem(
              theme: theme,
              icon: Icons.calendar_today_outlined,
              title: 'Tanggal',
              content: formattedDate,
            ),
             _buildDetailItem(
              theme: theme,
              icon: Icons.remove_red_eye_outlined,
              title: 'Jenis Pengamatan',
              content: report.observationType ?? 'Tidak ditentukan',
            ),
            _buildDetailItem(
              theme: theme,
              icon: Icons.description_outlined,
              title: 'Deskripsi Bahaya',
              content: report.hazardDescription ?? 'Tidak tersedia',
              isLongText: true,
            ),
            _buildDetailItem(
              theme: theme,
              icon: Icons.build_circle_outlined,
              title: 'Saran Tindakan',
              content: report.suggestedAction ?? 'Tidak tersedia',
              isLongText: true,
            ),
            _buildDetailItem(
              theme: theme,
              icon: Icons.person_outline,
              title: 'Dilaporkan oleh',
              content: report.reporterName ?? 'Tidak tersedia',
            ),
            if (report.lsbNumber != null && report.lsbNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(theme, 'Nomor LSB:', report.lsbNumber!),
            ],
          ],
        ),
      ),
    );
  }

  // Item detail dengan style yang disesuaikan
  Widget _buildDetailItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String content,
    bool isLongText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding vertikal
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22), // Ukuran ikon
          const SizedBox(width: 16), // Jarak ikon ke teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith( // Label lebih besar
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith( // Konten lebih besar
                    height: isLongText ? 1.4 : 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tombol bawah dengan style tema
  Widget _buildBottomButtons(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Padding
      decoration: BoxDecoration( // Beri sedikit shadow di atas tombol
         color: theme.colorScheme.surface,
         boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -4),
            )
         ]
      ),
      child: SizedBox( // Gunakan SizedBox untuk tinggi tombol yang konsisten
        width: double.infinity,
        height: 52, // Tinggi tombol
        child: ElevatedButton(
          onPressed: () => _navigateToHome(context),
          style: ElevatedButton.styleFrom(
            // Style diambil dari tema
            textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          child: const Text('Kembali ke Beranda'),
        ),
      ),
    );
  }

  // Navigasi ke home
  void _navigateToHome(BuildContext context) {
    // Gunakan '/home' jika itu rute MainScreen atau sesuaikan
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  // Detail row (jika masih diperlukan)
  Widget _buildDetailRow(ThemeData theme, String label, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
