import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ReportDetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isLongText;

  const ReportDetailSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isLongText = false,
  });

  @override
  Widget build(BuildContext context) {
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
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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

class StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const StatusBadge({super.key, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ReportHeaderInfo extends StatelessWidget {
  final String? lsbNumber;
  final String statusText;
  final Color statusColor;

  const ReportHeaderInfo({
    super.key,
    this.lsbNumber,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: statusColor.withAlpha(25),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nomor LSB
          Text(
            'No. LSB: ${lsbNumber ?? '-'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          // Status Chip
          StatusBadge(status: statusText, color: statusColor),
        ],
      ),
    );
  }
}
