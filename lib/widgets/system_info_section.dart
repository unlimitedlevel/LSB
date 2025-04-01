import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';

class SystemInfoSection extends StatelessWidget {
  final HazardReport report;
  final ThemeData? theme;

  const SystemInfoSection({super.key, required this.report, this.theme});

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm:ss', 'id_ID');
    final id = report.id ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: currentTheme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Sistem', style: currentTheme.textTheme.titleSmall),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.tag, size: 16),
              const SizedBox(width: 8),
              Text('ID Laporan: ', style: currentTheme.textTheme.labelMedium),
              Expanded(
                child: Text(
                  id.toString(),
                  style: currentTheme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text('Dibuat pada: ', style: currentTheme.textTheme.labelMedium),
              Text(
                report.createdAt != null
                    ? dateFormatter.format(report.createdAt!)
                    : 'N/A',
                style: currentTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          if (report.updatedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.update, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Terakhir diupdate: ',
                  style: currentTheme.textTheme.labelMedium,
                ),
                Text(
                  dateFormatter.format(report.updatedAt!),
                  style: currentTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          if (report.validatedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Divalidasi pada: ',
                  style: currentTheme.textTheme.labelMedium,
                ),
                Text(
                  dateFormatter.format(report.validatedAt!),
                  style: currentTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          if (report.validatedBy != null && report.validatedBy!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Divalidasi oleh: ',
                  style: currentTheme.textTheme.labelMedium,
                ),
                Text(
                  report.validatedBy!,
                  style: currentTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
