import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReportDetailScreen extends StatefulWidget {
  final HazardReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.mediumAnimation,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBanner(widget.report.status),
              const SizedBox(height: 24),

              // Informasi Pelapor
              AnimatedCard(
                onTap: () {},
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text('Informasi Pelapor', style: AppTheme.headingSm),
                        ],
                      ),
                      Divider(color: AppTheme.dividerColor, height: 24),
                      _buildInfoRow('Nama', widget.report.reporterName),
                      _buildInfoRow(
                        'Posisi / Jabatan',
                        widget.report.reporterPosition,
                      ),
                      _buildInfoRow(
                        'Tanggal Laporan',
                        DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(widget.report.reportDatetime),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detail Pengamatan
              AnimatedCard(
                onTap: () {},
                height: double.infinity,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text('Detail Pengamatan', style: AppTheme.headingSm),
                        ],
                      ),
                      Divider(color: AppTheme.dividerColor, height: 24),
                      _buildInfoRow('Lokasi', widget.report.location),
                      _buildInfoRow(
                        'Jenis Pengamatan',
                        widget.report.observationType,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Uraian Pengamatan Bahaya:',
                        style: AppTheme.labelLg,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          widget.report.hazardDescription,
                          style: AppTheme.bodyMd,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tindakan Intervensi / Saran Perbaikan:',
                        style: AppTheme.labelLg,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Text(
                          widget.report.suggestedAction,
                          style: AppTheme.bodyMd,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gambar
              if (widget.report.imagePath != null &&
                  widget.report.imagePath!.isNotEmpty)
                AnimatedCard(
                  onTap: () {},
                  height: double.infinity,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.image_rounded,
                              color: AppTheme.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text('Dokumentasi', style: AppTheme.headingSm),
                          ],
                        ),
                        Divider(color: AppTheme.dividerColor, height: 24),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.report.imagePath!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: AppTheme.backgroundLight,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: AppTheme.backgroundLight,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          color: AppTheme.textLight,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gagal memuat gambar',
                                          style: AppTheme.labelMd,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Status Lanjutan
              if (widget.report.status != 'submitted')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: AnimatedCard(
                    onTap: () {},
                    height: double.infinity,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.update,
                                color: AppTheme.primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Status Tindak Lanjut',
                                style: AppTheme.headingSm,
                              ),
                            ],
                          ),
                          Divider(color: AppTheme.dividerColor, height: 24),
                          _buildInfoRow(
                            'Status:',
                            widget.report.status == 'processing'
                                ? 'Sedang Diproses'
                                : widget.report.status == 'completed'
                                ? 'Selesai'
                                : 'Dibatalkan',
                          ),
                          if (widget.report.validationNotes != null &&
                              widget.report.validationNotes!.isNotEmpty)
                            _buildInfoRow(
                              'Catatan Validasi:',
                              widget.report.validationNotes!,
                            ),
                          if (widget.report.validatedBy != null)
                            _buildInfoRow(
                              'Divalidasi oleh:',
                              widget.report.validatedBy!,
                            ),
                          if (widget.report.followUp != null &&
                              widget.report.followUp!.isNotEmpty)
                            _buildInfoRow(
                              'Tindak Lanjut:',
                              widget.report.followUp!,
                            ),
                          if (widget.report.followedUpBy != null)
                            _buildInfoRow(
                              'Ditindaklanjuti oleh:',
                              widget.report.followedUpBy!,
                            ),
                          if (widget.report.closingNotes != null &&
                              widget.report.closingNotes!.isNotEmpty)
                            _buildInfoRow(
                              'Catatan Penutupan:',
                              widget.report.closingNotes!,
                            ),
                          if (widget.report.closedAt != null)
                            _buildInfoRow(
                              'Tanggal Selesai:',
                              DateFormat(
                                'dd MMMM yyyy, HH:mm',
                              ).format(widget.report.closedAt!),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String? status) {
    Color color;
    String message;
    IconData icon = _getStatusIcon(status);

    switch (status) {
      case 'submitted':
        color = AppTheme.info;
        message = 'Laporan telah terkirim dan menunggu validasi';
        break;
      case 'validated':
        color = AppTheme.warning;
        message = 'Laporan telah divalidasi dan menunggu tindak lanjut';
        break;
      case 'in_progress':
        color = AppTheme.accentColor;
        message = 'Laporan sedang dalam proses tindak lanjut';
        break;
      case 'closed':
        color = AppTheme.success;
        message = 'Laporan telah ditutup dan selesai ditindaklanjuti';
        break;
      default:
        color = AppTheme.textLight;
        message = 'Status laporan tidak diketahui';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMd.copyWith(
                color: color.withOpacity(0.9),
                fontWeight: AppTheme.fontWeightSemiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'submitted':
        return Icons.assignment_turned_in_rounded;
      case 'validated':
        return Icons.verified_rounded;
      case 'in_progress':
        return Icons.engineering_rounded;
      case 'closed':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: AppTheme.labelLg)),
          Expanded(child: Text(value, style: AppTheme.bodyMd)),
        ],
      ),
    );
  }
}
