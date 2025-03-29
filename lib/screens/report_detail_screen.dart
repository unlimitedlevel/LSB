import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import '../config/app_theme.dart';

class ReportDetailScreen extends StatelessWidget {
  final HazardReport report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    final formattedDate =
        report.reportDatetime != null
            ? dateFormatter.format(report.reportDatetime!)
            : 'Tanggal tidak tersedia';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Laporan
            if (report.imagePath != null && report.imagePath!.isNotEmpty)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  report.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gambar tidak tersedia',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Status & Informasi Dasar
            Container(
              width: double.infinity,
              color: report.statusColor.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nomor LSB
                      if (report.lsbNumber != null &&
                          report.lsbNumber!.isNotEmpty)
                        Text(
                          'No. LSB: ${report.lsbNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'No. LSB: -',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      // Status Chip
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

            // Detail Laporan
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi
                  _buildDetailSection(
                    title: 'Lokasi',
                    content: report.location ?? 'Tidak tersedia',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Laporan
                  _buildDetailSection(
                    title: 'Tanggal Laporan',
                    content: formattedDate,
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),

                  // Pelapor
                  _buildDetailSection(
                    title: 'Dilaporkan oleh',
                    content:
                        '${report.reporterName ?? 'Tidak tersedia'} (${report.reporterPosition ?? 'Jabatan tidak tersedia'})',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Jenis Pengamatan
                  _buildDetailSection(
                    title: 'Jenis Pengamatan',
                    content: report.observationType ?? 'Unsafe Condition',
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi Bahaya
                  _buildDetailSection(
                    title: 'Deskripsi Bahaya',
                    content: report.hazardDescription ?? 'Tidak tersedia',
                    icon: Icons.warning,
                    isLongText: true,
                  ),
                  const SizedBox(height: 16),

                  // Saran Tindakan
                  _buildDetailSection(
                    title: 'Saran Tindakan',
                    content: report.suggestedAction ?? 'Tidak tersedia',
                    icon: Icons.build,
                    isLongText: true,
                  ),
                  const SizedBox(height: 24),

                  // Informasi Sistem
                  _buildSystemInfoSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
    bool isLongText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfoSection() {
    final dateFormatter = DateFormat('dd MMM yyyy HH:mm', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Informasi Sistem',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Tanggal dibuat
        if (report.createdAt != null)
          _buildInfoRow('Dibuat pada', dateFormatter.format(report.createdAt!)),

        // Tanggal diupdate
        if (report.updatedAt != null)
          _buildInfoRow(
            'Terakhir diupdate',
            dateFormatter.format(report.updatedAt!),
          ),

        // Informasi validasi
        if (report.validatedAt != null)
          _buildInfoRow(
            'Divalidasi pada',
            dateFormatter.format(report.validatedAt!),
          ),

        if (report.validatedBy != null && report.validatedBy!.isNotEmpty)
          _buildInfoRow('Divalidasi oleh', report.validatedBy!),

        if (report.validationNotes != null &&
            report.validationNotes!.isNotEmpty)
          _buildInfoRow('Catatan validasi', report.validationNotes!),

        // Informasi tindak lanjut
        if (report.followedUpAt != null)
          _buildInfoRow(
            'Ditindaklanjuti pada',
            dateFormatter.format(report.followedUpAt!),
          ),

        if (report.followedUpBy != null && report.followedUpBy!.isNotEmpty)
          _buildInfoRow('Ditindaklanjuti oleh', report.followedUpBy!),

        if (report.followUp != null && report.followUp!.isNotEmpty)
          _buildInfoRow('Tindakan', report.followUp!),

        // Informasi penutupan
        if (report.closedAt != null)
          _buildInfoRow('Ditutup pada', dateFormatter.format(report.closedAt!)),

        if (report.closedBy != null && report.closedBy!.isNotEmpty)
          _buildInfoRow('Ditutup oleh', report.closedBy!),

        if (report.closingNotes != null && report.closingNotes!.isNotEmpty)
          _buildInfoRow('Catatan penutupan', report.closingNotes!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
