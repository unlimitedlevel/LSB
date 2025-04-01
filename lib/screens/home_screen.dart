import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/hazard_report.dart';
import 'report_form_screen.dart';
import 'package:intl/intl.dart';
import 'report_detail_screen.dart';
import '../services/auth_service.dart'; // Import AuthService

class HomeScreen extends StatefulWidget {
  final AuthService authService; // Tambahkan parameter authService

  const HomeScreen({super.key, required this.authService}); // Update constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HazardReport>> _reportsFuture;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isSupabaseInitialized = false;
  bool _isTableCreated = false;
  String _tableCreationMessage = '';
  final FocusNode _focusNode = FocusNode();
  WidgetsBindingObserver? _lifecycleObserver;

  // State untuk filter status
  String _selectedStatusFilter = 'Semua'; // Default filter
  final List<String> _statusOptions = ['Semua', 'Submitted', 'Validated', 'In Progress', 'Completed']; // Pilihan status

  @override
  void initState() {
    super.initState();
    _reportsFuture = Future.value([]);
    _checkSupabaseInitialization();

    _lifecycleObserver = _AppLifecycleObserver(_loadReports);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
    }
    super.dispose();
  }

  void _checkSupabaseInitialization() {
    try {
      Supabase.instance.client;
      if (mounted) {
        setState(() {
          _isSupabaseInitialized = true;
        });
      }
      _initializeAsyncDependencies();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSupabaseInitialized = false;
          _reportsFuture = Future.value([]);
        });
      }
      debugPrint('Supabase not initialized: $e');
    }
  }

  Future<void> _initializeAsyncDependencies() async {
    await _createTableIfNeeded();
    _loadReports();
  }

  Future<void> _createTableIfNeeded() async {
    if (!_isSupabaseInitialized) return;

    String message;
    bool created = false;
    try {
      created = await _supabaseService.createTableIfNotExists();
      message =
          created
              ? 'Tabel hazard_reports siap digunakan.'
              : 'Tabel hazard_reports tidak ditemukan. Mohon buat manual.';
    } catch (e) {
      message = 'Gagal memeriksa/membuat tabel: ${e.toString()}';
      debugPrint('Error checking/creating table: $e');
      created = false;
    }

    if (mounted) {
      setState(() {
        _isTableCreated = created;
        _tableCreationMessage = message;
      });
    }
  }

  void _loadReports() {
    // Panggil getHazardReports dengan filter yang dipilih
    if (_isSupabaseInitialized && _isTableCreated) {
      if (mounted) {
        setState(() {
          // Panggil service dengan filter status
          _reportsFuture = _supabaseService.getHazardReports(statusFilter: _selectedStatusFilter);
        });
      }
    } else if (_isSupabaseInitialized && !_isTableCreated) {
      if (mounted) {
        setState(() {
          _reportsFuture = Future.error(
            Exception(
              _tableCreationMessage.isNotEmpty
                  ? _tableCreationMessage
                  : 'Tabel tidak ditemukan.',
            ),
          );
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _reportsFuture = Future.value([]);
        });
      }
    }
  }

  // Fungsi ini tidak lagi digunakan karena FAB dipindah
  // void _navigateAndRefresh() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ReportFormScreen()),
  //   ).then((result) {
  //     if (result == true || result == null) {
  //       _loadReports();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildMainContent(theme);
  }

  Widget _buildInfoBanner(
    String message,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: iconColor.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    List<Widget> statusWidgets = [];

    if (!_isSupabaseInitialized) {
      statusWidgets.add(
        _buildInfoBanner(
          'Mode Demo Aktif. Konfigurasi Supabase di .env untuk fitur penuh.',
          Icons.info_outline,
          theme.colorScheme.secondaryContainer.withOpacity(0.5),
          theme.colorScheme.onSecondaryContainer,
        ),
      );
    }

    if (kIsWeb) {
      statusWidgets.add(
        _buildInfoBanner(
          'Berjalan di Web. Fitur seperti kamera mungkin terbatas.',
          Icons.web_asset_outlined,
          theme.colorScheme.tertiaryContainer.withOpacity(0.5),
          theme.colorScheme.onTertiaryContainer,
        ),
      );
    }

    if (_isSupabaseInitialized) {
      final Color bgColor =
          _isTableCreated
              ? Colors.green.shade50
              : theme.colorScheme.errorContainer.withOpacity(0.5);
      final Color fgColor =
          _isTableCreated
              ? Colors.green.shade900
              : theme.colorScheme.onErrorContainer;
      final IconData icon =
          _isTableCreated ? Icons.check_circle_outline : Icons.error_outline;
      final String mainMessage =
          _isTableCreated
              ? 'Terhubung & Tabel Siap.'
              : 'Terhubung, tapi Tabel Bermasalah.';

      statusWidgets.add(
        Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fgColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: fgColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_tableCreationMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          _tableCreationMessage,
                          style: TextStyle(
                            fontSize: 11,
                            color: fgColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (statusWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(children: statusWidgets);
  }

  // Widget untuk membangun filter chips
  Widget _buildFilterChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SizedBox(
        height: 40, // Tinggi tetap untuk chip row
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _statusOptions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final status = _statusOptions[index];
            final isSelected = status == _selectedStatusFilter;
            return FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatusFilter = status;
                  });
                  _loadReports(); // Muat ulang data dengan filter baru
                }
              },
              selectedColor: theme.colorScheme.primaryContainer.withOpacity(0.8),
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))),
              visualDensity: VisualDensity.compact,
              showCheckmark: false, // Bisa diaktifkan jika suka
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Laporan'),
        // Contoh tombol logout di AppBar
        actions: [
           IconButton(
             icon: const Icon(Icons.logout),
             tooltip: 'Logout',
             onPressed: () async {
               await widget.authService.signOut();
               // Navigasi akan ditangani oleh StreamBuilder di main.dart
             },
           ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadReports(); // Refresh tetap memuat dengan filter terakhir
        },
        child: Column(
          children: [
            _buildStatusSection(theme),
            _buildFilterChips(theme), // Tambahkan filter chips di sini
            const Divider(height: 1, thickness: 1), // Pemisah visual
            Expanded(
              child: FutureBuilder<List<HazardReport>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingIndicator();
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Cek apakah ini karena filter atau memang kosong
                    if (_selectedStatusFilter != 'Semua') {
                       return _buildEmptyFilterResultWidget(theme);
                    } else if (_isSupabaseInitialized && _isTableCreated) {
                      return _buildEmptyListWidget();
                    } else {
                      // Tampilkan pesan error jika tabel tidak ada atau Supabase belum siap
                      return _buildErrorWidget(_tableCreationMessage.isNotEmpty
                          ? _tableCreationMessage
                          : 'Tabel tidak ditemukan atau Supabase belum siap.');
                    }
                  } else {
                    final reports = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildReportCard(report, theme);
                      },
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor.withOpacity(0.1),
                        indent: 16,
                        endIndent: 16,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Laporan',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyListWidget() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_outlined,
              size: 60,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Laporan',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan tombol "Scan LSB" untuk menambahkan laporan baru.', // Sesuaikan teks
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildEmptyFilterResultWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 60,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Laporan',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada laporan dengan status "${_selectedStatusFilter}". Coba filter lain.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                 color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- MODIFIKASI TAMPILAN KARTU LAPORAN ---
  Widget _buildReportCard(HazardReport report, ThemeData theme) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final formattedDate =
        report.reportDatetime != null
            ? dateFormatter.format(report.reportDatetime!)
            : 'Tanggal tidak tersedia';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      elevation: 1.5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Teruskan authService ke ReportDetailScreen jika diperlukan
              builder: (context) => ReportDetailScreen(report: report /*, authService: widget.authService */),
            ),
          ).then((_) => _loadReports()); // Muat ulang setelah kembali dari detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(report.imagePath, theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            report.location ?? 'Lokasi Tidak Diketahui',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(report, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (report.hazardDescription != null &&
                        report.hazardDescription!.isNotEmpty)
                      Text(
                        report.hazardDescription!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (report.observationType != null)
                          Text(
                            'Tipe: ${report.observationType}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (report.lsbNumber != null &&
                            report.lsbNumber!.isNotEmpty)
                          Text(
                            'LSB: ${report.lsbNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --- AKHIR MODIFIKASI KARTU ---


  Widget _buildThumbnail(String? imageUrl, ThemeData theme) {
    Widget placeholder = Center(
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 30,
      ),
    );

    Widget errorWidget = Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        size: 30,
      ),
    );

    return Container(
      width: 70,
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Sesuaikan radius
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child:
          (imageUrl != null &&
                  imageUrl.isNotEmpty &&
                  Uri.tryParse(imageUrl)?.hasAbsolutePath == true)
              ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image $imageUrl: $error');
                  return errorWidget;
                },
              )
              : placeholder,
    );
  }

  Widget _buildStatusChip(HazardReport report, ThemeData theme) {
    final Color textColor =
        report.statusColor.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;

    return Chip(
      label: Text(report.statusTranslated),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: report.statusColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumed;

  _AppLifecycleObserver(this.onResumed);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
