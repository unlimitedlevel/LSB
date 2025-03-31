import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import 'report_detail_widgets.dart';

class SystemInfoSection extends StatelessWidget {
  final HazardReport report;

  const SystemInfoSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
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
          InfoRow(
            label: 'Dibuat pada',
            value: dateFormatter.format(report.createdAt!),
          ),

        // Tanggal diupdate
        if (report.updatedAt != null)
          InfoRow(
            label: 'Terakhir diupdate',
            value: dateFormatter.format(report.updatedAt!),
          ),

        // Informasi validasi
        if (report.validatedAt != null)
          InfoRow(
            label: 'Divalidasi pada',
            value: dateFormatter.format(report.validatedAt!),
          ),

        if (report.validatedBy != null && report.validatedBy!.isNotEmpty)
          InfoRow(label: 'Divalidasi oleh', value: report.validatedBy!),

        if (report.validationNotes != null &&
            report.validationNotes!.isNotEmpty)
          InfoRow(label: 'Catatan validasi', value: report.validationNotes!),

        // Informasi tindak lanjut
        if (report.followedUpAt != null)
          InfoRow(
            label: 'Ditindaklanjuti pada',
            value: dateFormatter.format(report.followedUpAt!),
          ),

        if (report.followedUpBy != null && report.followedUpBy!.isNotEmpty)
          InfoRow(label: 'Ditindaklanjuti oleh', value: report.followedUpBy!),

        if (report.followUp != null && report.followUp!.isNotEmpty)
          InfoRow(label: 'Tindakan', value: report.followUp!),

        // Informasi penutupan
        if (report.closedAt != null)
          InfoRow(
            label: 'Ditutup pada',
            value: dateFormatter.format(report.closedAt!),
          ),

        if (report.closedBy != null && report.closedBy!.isNotEmpty)
          InfoRow(label: 'Ditutup oleh', value: report.closedBy!),

        if (report.closingNotes != null && report.closingNotes!.isNotEmpty)
          InfoRow(label: 'Catatan penutupan', value: report.closingNotes!),
      ],
    );
  }
}
