import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import '../widgets/report_detail_widgets.dart';
import '../widgets/system_info_section.dart';

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
            ReportHeaderInfo(
              lsbNumber: report.lsbNumber,
              statusText: report.statusTranslated,
              statusColor: report.statusColor,
            ),

            // Detail Laporan
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi
                  ReportDetailSection(
                    title: 'Lokasi',
                    content: report.location ?? 'Tidak tersedia',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Laporan
                  ReportDetailSection(
                    title: 'Tanggal Laporan',
                    content: formattedDate,
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),

                  // Pelapor
                  ReportDetailSection(
                    title: 'Dilaporkan oleh',
                    content:
                        '${report.reporterName ?? 'Tidak tersedia'} (${report.reporterPosition ?? 'Jabatan tidak tersedia'})',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Jenis Pengamatan
                  ReportDetailSection(
                    title: 'Jenis Pengamatan',
                    content: report.observationType ?? 'Unsafe Condition',
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi Bahaya
                  ReportDetailSection(
                    title: 'Deskripsi Bahaya',
                    content: report.hazardDescription ?? 'Tidak tersedia',
                    icon: Icons.warning,
                    isLongText: true,
                  ),
                  const SizedBox(height: 16),

                  // Saran Tindakan
                  ReportDetailSection(
                    title: 'Saran Tindakan',
                    content: report.suggestedAction ?? 'Tidak tersedia',
                    icon: Icons.build,
                    isLongText: true,
                  ),
                  const SizedBox(height: 24),

                  // Informasi Sistem
                  SystemInfoSection(report: report),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
