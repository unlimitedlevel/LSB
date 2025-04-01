import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ReportDetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final bool isLongText;
  final ThemeData? theme;

  const ReportDetailSection({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.isLongText = false,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: currentTheme.colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: currentTheme.textTheme.labelMedium?.copyWith(
                  color: currentTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: currentTheme.textTheme.bodyLarge?.copyWith(
                  height: isLongText ? 1.4 : 1.2,
                ),
              ),
            ],
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
  final ThemeData? theme;

  const ReportHeaderInfo({
    super.key,
    this.lsbNumber,
    required this.statusText,
    required this.statusColor,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (lsbNumber != null && lsbNumber!.isNotEmpty)
            Text(
              'No. LSB: $lsbNumber',
              style: currentTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const SizedBox(),
          Chip(
            label: Text(statusText),
            labelStyle: currentTheme.textTheme.labelSmall?.copyWith(
              color:
                  statusColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: statusColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            visualDensity: VisualDensity.compact,
            side: BorderSide.none,
          ),
        ],
      ),
    );
  }
}
