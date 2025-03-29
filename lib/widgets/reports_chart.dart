import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/hazard_report.dart';

class ReportsChart extends StatelessWidget {
  final List<HazardReport> reports;
  final bool showLabels;
  final double barWidth;
  final bool isWeekly;

  const ReportsChart({
    Key? key,
    required this.reports,
    this.showLabels = true,
    this.barWidth = 16,
    this.isWeekly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxCount() + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.shade800,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final count = _getCountForIndex(groupIndex);
                return BarTooltipItem(
                  '$count laporan',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  final labelText =
                      isWeekly
                          ? _getWeekdayLabel(index)
                          : _getMonthLabel(index);

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labelText,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            isWeekly ? 7 : 6,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _getCountForIndex(index).toDouble(),
                  color: _getBarColor(index, context),
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  double _getMaxCount() {
    if (reports.isEmpty) return 10;

    final counts = List.generate(
      isWeekly ? 7 : 6,
      (index) => _getCountForIndex(index),
    );

    return counts.reduce((max, count) => count > max ? count : max).toDouble();
  }

  int _getCountForIndex(int index) {
    if (reports.isEmpty) return 0;

    final now = DateTime.now();

    if (isWeekly) {
      // Weekday: 0 = Monday, 6 = Sunday
      return reports.where((report) {
        final reportDate = report.reportDatetime;
        final dayDifference = now.difference(reportDate).inDays;
        // Hanya laporan dalam 7 hari terakhir
        if (dayDifference > 7) return false;

        // Mengonversi weekday dari DateTime (1-7, dengan 1=Monday) ke index (0-6)
        final weekday = reportDate.weekday - 1; // 0 = Monday
        return weekday == index;
      }).length;
    } else {
      // Bulan: 0 = Bulan ini, 1 = Bulan lalu, dst (hingga 5 bulan ke belakang)
      return reports.where((report) {
        final reportDate = report.reportDatetime;
        final month = reportDate.month;
        final year = reportDate.year;

        final targetMonth = now.month - index;
        final targetYear = now.year;

        // Adjustment for previous year
        final adjustedMonth = targetMonth <= 0 ? targetMonth + 12 : targetMonth;
        final adjustedYear = targetMonth <= 0 ? targetYear - 1 : targetYear;

        return month == adjustedMonth && year == adjustedYear;
      }).length;
    }
  }

  String _getMonthLabel(int index) {
    final now = DateTime.now();
    final month = now.month - index;
    final adjustedMonth = month <= 0 ? month + 12 : month;

    switch (adjustedMonth) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'Mei';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Agt';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      case 12:
        return 'Des';
      default:
        return '';
    }
  }

  String _getWeekdayLabel(int index) {
    // index: 0 = Monday, 6 = Sunday
    switch (index) {
      case 0:
        return 'Sen';
      case 1:
        return 'Sel';
      case 2:
        return 'Rab';
      case 3:
        return 'Kam';
      case 4:
        return 'Jum';
      case 5:
        return 'Sab';
      case 6:
        return 'Min';
      default:
        return '';
    }
  }

  Color _getBarColor(int index, BuildContext context) {
    if (isWeekly) {
      const baseColor = Color(0xFF2A64FE);
      // Semakin mendekati hari ini, semakin gelap warnanya
      final today = DateTime.now().weekday - 1; // 0 = Monday

      if (index == today) {
        return baseColor;
      }

      final factor = 0.5 + (0.5 * (6 - (today - index).abs()) / 6);
      return baseColor.withOpacity(factor);
    } else {
      // Gradien warna dari biru muda ke biru tua (bulan terlama ke bulan terkini)
      final colors = [
        const Color(0xFFAAD7FF),
        const Color(0xFF7BBBFF),
        const Color(0xFF5DA6FF),
        const Color(0xFF4395FF),
        const Color(0xFF2A78FE),
        const Color(0xFF0038FF),
      ];

      return colors[index % colors.length];
    }
  }
}
