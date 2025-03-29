import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import '../services/report_service.dart';
import '../widgets/user_header.dart';
import '../widgets/gradient_card.dart';
import '../widgets/reports_chart.dart';
import 'report_form_screen.dart';
import 'report_detail_screen.dart';

class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({Key? key}) : super(key: key);

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  late Future<List<HazardReport>> _reportsFuture;
  bool _isSupabaseInitialized = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    _loadInitialData();
  }

  void _loadInitialData() {
    try {
      // Cek apakah Supabase sudah diinisialisasi
      _reportService.checkSupabaseInitialization();
      setState(() {
        _isSupabaseInitialized = true;
        _loadReports();
      });
    } catch (e) {
      debugPrint('Error checking Supabase: $e');
      setState(() {
        _isSupabaseInitialized = false;
        _reportsFuture = Future.value(_reportService.getDummyReports());
      });
    }
  }

  void _loadReports() {
    if (_isSupabaseInitialized) {
      _reportsFuture = _reportService.getHazardReports();
    } else {
      _reportsFuture = Future.value(_reportService.getDummyReports());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<HazardReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Terjadi kesalahan: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadInitialData();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data ?? [];
          final openReports =
              reports.where((r) => r.status != 'closed').toList();
          final closedReports =
              reports.where((r) => r.status == 'closed').toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: UserHeader(
                    userName: 'Admin',
                    userPosition: 'Supervisor',
                    totalReports: reports.length,
                    pendingReports: openReports.length,
                    closedReports: closedReports.length,
                    onNotificationTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifikasi akan segera hadir'),
                        ),
                      );
                    },
                    onProfileTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil pengguna akan segera hadir'),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ringkasan Laporan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _loadReports();
                            });
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 16),
                              SizedBox(width: 4),
                              Text('Refresh'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ReportsChart(reports: reports, isWeekly: false),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Unsafe Action',
                            value:
                                reports
                                    .where(
                                      (r) =>
                                          r.observationType == 'Unsafe Action',
                                    )
                                    .length
                                    .toString(),
                            icon: Icons.person_outlined,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFF9800), Color(0xFFED6C02)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Unsafe Condition',
                            value:
                                reports
                                    .where(
                                      (r) =>
                                          r.observationType ==
                                          'Unsafe Condition',
                                    )
                                    .length
                                    .toString(),
                            icon: Icons.warning_outlined,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2196F3), Color(0xFF0069C0)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Aktif'),
                      Tab(text: 'Selesai'),
                    ],
                    onTap: (index) {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(reports),
                _buildReportsList(openReports),
                _buildReportsList(closedReports),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportFormScreen()),
          ).then((_) {
            setState(() {
              _loadReports();
            });
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Laporan Baru'),
      ),
    );
  }

  Widget _buildReportsList(List<HazardReport> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 60, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0
                  ? 'Belum ada laporan sumber bahaya'
                  : _selectedTab == 1
                  ? 'Belum ada laporan aktif'
                  : 'Belum ada laporan yang selesai',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(HazardReport report) {
    final reportDate = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(report.reportDatetime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          ).then((_) {
            setState(() {
              _loadReports();
            });
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.imagePath != null) ...[
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  report.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          report.observationType,
                          style: TextStyle(
                            color:
                                report.observationType == 'Unsafe Action'
                                    ? Colors.deepOrange
                                    : Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                            report.observationType == 'Unsafe Action'
                                ? Colors.deepOrange.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text(
                          report.statusTranslated,
                          style: TextStyle(
                            color: report.statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: report.statusColor.withOpacity(0.1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.hazardDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reportDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          report.reporterName.isNotEmpty
                              ? report.reporterName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.reporterName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              report.reporterPosition,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
