import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hazard_report.dart';
import 'package:flutter/services.dart'; // Import untuk HapticFeedback
import '../widgets/report_detail_widgets.dart';
import '../widgets/system_info_section.dart';
import '../config/app_theme.dart'; // Import AppTheme
import '../services/auth_service.dart'; // Import AuthService (diperlukan untuk info user)
import '../services/supabase_service.dart'; // Import service untuk aksi

// Ubah menjadi StatefulWidget
class ReportDetailScreen extends StatefulWidget {
  final HazardReport report;
  // Terima AuthService jika diperlukan untuk info user
  // final AuthService authService;

  const ReportDetailScreen({
    super.key,
    required this.report,
    // required this.authService, // Aktifkan jika diperlukan
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late HazardReport _currentReport; // State untuk menampung data laporan
  final SupabaseService _supabaseService = SupabaseService(); // Instance service
  final AuthService _authService = AuthService(); // Instance AuthService
  bool _isLoadingAction = false; // State untuk loading aksi

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report; // Inisialisasi state dengan data awal
  }

  // Helper untuk format tanggal (bisa null)
  String _formatNullableDate(DateTime? date, String format) {
    if (date == null) return 'Belum ditentukan';
    return DateFormat(format, 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Gunakan _currentReport dari state
    final dateFormatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    final formattedDate = _formatNullableDate(_currentReport.reportDatetime, 'dd MMMM yyyy, HH:mm');
    final formattedDueDate = _formatNullableDate(_currentReport.dueDate, 'dd MMMM yyyy');

    return Scaffold(
      // AppBar lebih modern
      appBar: AppBar(
        title: Text(_currentReport.lsbNumber ?? 'Detail Laporan'), // Gunakan _currentReport
        backgroundColor: theme.scaffoldBackgroundColor, // Samakan dengan background
        foregroundColor: theme.colorScheme.onSurface, // Warna teks sesuai background
        elevation: 0, // Hilangkan shadow
        systemOverlayStyle: SystemUiOverlayStyle( // Sesuaikan status bar
          statusBarColor: theme.scaffoldBackgroundColor,
          statusBarIconBrightness: theme.brightness == Brightness.light ? Brightness.dark : Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding utama untuk seluruh konten
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Gambar
              _buildImageSection(context, theme),
              const SizedBox(height: 16), // Spasi setelah gambar

              // --- Kartu Informasi Utama ---
              _buildInfoCard(
                theme: theme,
                children: [
                  ReportHeaderInfo( // Pindahkan header ke dalam Card
                    lsbNumber: _currentReport.lsbNumber, // Gunakan _currentReport
                    statusText: _currentReport.statusTranslated, // Gunakan _currentReport
                    statusColor: _currentReport.statusColor, // Gunakan _currentReport
                    theme: theme,
                  ),
                  const Divider(height: 24), // Pemisah
                  ReportDetailSection(
                    title: 'Lokasi Kejadian',
                    content: _currentReport.location ?? 'Tidak tersedia', // Gunakan _currentReport
                    icon: Icons.location_on_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Tanggal & Waktu Laporan',
                    content: formattedDate, // Gunakan formattedDate dari state
                    icon: Icons.calendar_today_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                   ReportDetailSection(
                    title: 'Jenis Pengamatan',
                    content: _currentReport.observationType ?? 'Tidak ditentukan', // Gunakan _currentReport
                    icon: Icons.remove_red_eye_outlined,
                    theme: theme,
                  ),
                ],
              ),

              // --- Kartu Detail Pelapor ---
              _buildInfoCard(
                theme: theme,
                children: [
                   ReportDetailSection(
                    title: 'Dilaporkan oleh',
                    content: _currentReport.reporterName ?? 'Anonim', // Gunakan _currentReport
                    icon: Icons.person_outline,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Jabatan/Posisi',
                    content: _currentReport.reporterPosition ?? 'Tidak diketahui', // Gunakan _currentReport
                    icon: Icons.work_outline_rounded, // Ikon berbeda
                    theme: theme,
                  ),
                ],
              ),

              // --- Kartu Deskripsi & Saran ---
              _buildInfoCard(
                theme: theme,
                children: [
                  ReportDetailSection(
                    title: 'Deskripsi Bahaya',
                    content: _currentReport.hazardDescription ?? 'Tidak ada deskripsi.', // Gunakan _currentReport
                    icon: Icons.description_outlined,
                    isLongText: true,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Saran Tindakan Perbaikan',
                    content: _currentReport.suggestedAction ?? 'Tidak ada saran.', // Gunakan _currentReport
                    icon: Icons.build_circle_outlined,
                    isLongText: true,
                    theme: theme,
                  ),
                ],
              ),

              // --- Kartu Workflow ---
              _buildInfoCard(
                theme: theme,
                children: [
                  Text("Status & Tindak Lanjut", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  ReportDetailSection(
                    title: 'Status Validasi',
                    content: _currentReport.validationStatus ?? 'Pending',
                    icon: _currentReport.validationStatus == 'Valid' ? Icons.check_circle_outline : (_currentReport.validationStatus == 'Invalid' ? Icons.cancel_outlined : Icons.pending_outlined),
                    theme: theme,
                  ),
                   const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Prioritas',
                    content: _currentReport.priority ?? 'Belum diatur',
                    icon: Icons.priority_high_rounded,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Ditugaskan Kepada',
                    content: _currentReport.assignedToName ?? 'Belum ditugaskan',
                    icon: Icons.assignment_ind_outlined,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  ReportDetailSection(
                    title: 'Batas Waktu',
                    content: formattedDueDate, // Gunakan formattedDueDate
                    icon: Icons.timer_outlined,
                    theme: theme,
                  ),
                  // --- Tampilkan Riwayat Tindak Lanjut ---
                  if (_currentReport.followUpActions != null && _currentReport.followUpActions!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text("Riwayat Tindak Lanjut:", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildFollowUpHistory(theme), // Panggil widget riwayat
                  ] else ... [
                     const SizedBox(height: 16), // Beri spasi jika tidak ada riwayat
                     Center(child: Text("Belum ada tindak lanjut.", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  ]
                  // --- Akhir Riwayat Tindak Lanjut ---
                ],
              ),


              // --- Kartu Informasi Sistem ---
              _buildInfoCard(
                theme: theme,
                children: [
                  SystemInfoSection(report: _currentReport, theme: theme), // Gunakan _currentReport
                ],
              ),

              const SizedBox(height: 20), // Spasi di akhir

              // --- Placeholder Tombol Aksi Workflow ---
              _buildWorkflowActions(theme),

              const SizedBox(height: 20), // Spasi tambahan di bawah
            ],
          ),
        ),
      ),
    );
  }

  // --- Fungsi untuk Aksi Workflow ---

  // Menampilkan dialog untuk menugaskan laporan
  Future<void> _showAssignDialog() async {
    String? assignedUserName; // Variabel untuk menyimpan nama input
    final nameController = TextEditingController();

    final bool? shouldAssign = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugaskan Laporan'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nama Penanggung Jawab'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              assignedUserName = nameController.text.trim();
              if (assignedUserName != null && assignedUserName!.isNotEmpty) {
                Navigator.pop(context, true); // Tutup dialog dan konfirmasi
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Tugaskan'),
          ),
        ],
      ),
    );

    if (shouldAssign == true && assignedUserName != null) {
      setState(() => _isLoadingAction = true);
      try {
        // TODO: Idealnya User ID diambil dari daftar pengguna atau pencarian
        String placeholderUserId = 'user-placeholder-id';
        bool success = await _supabaseService.assignReport(_currentReport.id!, placeholderUserId, assignedUserName!);

        if (success && mounted) {
          setState(() {
            _currentReport = _currentReport.copyWith(
              assignedToName: assignedUserName,
              assignedToUserId: placeholderUserId,
              status: 'in_progress',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Laporan ditugaskan ke $assignedUserName'), backgroundColor: Colors.green),
            );
          });
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Gagal menugaskan laporan'), backgroundColor: Colors.red),
           );
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
      } finally {
        if (mounted) {
          setState(() => _isLoadingAction = false);
        }
      }
    }
     nameController.dispose();
  }

  // Fungsi untuk menampilkan dialog validasi
  Future<void> _showValidateDialog() async {
    String? selectedValidationStatus;
    final notesController = TextEditingController();

    final bool? shouldValidate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Validasi Laporan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih status validasi:'),
                    RadioListTile<String>(
                      title: const Text('Valid'),
                      value: 'Valid',
                      groupValue: selectedValidationStatus,
                      onChanged: (value) => setDialogState(() => selectedValidationStatus = value),
                    ),
                    RadioListTile<String>(
                      title: const Text('Invalid'),
                      value: 'Invalid',
                      groupValue: selectedValidationStatus,
                      onChanged: (value) => setDialogState(() => selectedValidationStatus = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Catatan Validasi (opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedValidationStatus != null) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih status validasi!'), backgroundColor: Colors.orange),
                      );
                    }
                  },
                  child: const Text('Simpan Validasi'),
                ),
              ],
            );
          },
        );
      },
    );

     if (shouldValidate == true && selectedValidationStatus != null) {
      setState(() => _isLoadingAction = true);
      try {
        // Gunakan nama pengguna yang login sebagai validator
        String validatorName = _authService.currentUserDisplayName;
        String? notes = notesController.text.trim().isNotEmpty ? notesController.text.trim() : null;

        bool success = await _supabaseService.validateReport(_currentReport.id!, selectedValidationStatus!, validatorName, notes);

        if (success && mounted) {
          setState(() {
            _currentReport = _currentReport.copyWith(
              validationStatus: selectedValidationStatus,
              validationNotes: notes,
              validatedBy: validatorName,
              validatedAt: DateTime.now(),
              status: selectedValidationStatus == 'Valid' ? 'validated' : _currentReport.status,
            );
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status validasi diperbarui menjadi $selectedValidationStatus'), backgroundColor: Colors.green),
            );
          });
        } else if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Gagal memperbarui status validasi'), backgroundColor: Colors.red),
           );
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
      } finally {
         if (mounted) {
          setState(() => _isLoadingAction = false);
        }
      }
    }
    notesController.dispose();
  }

  // Fungsi untuk menampilkan dialog tambah tindak lanjut
  Future<void> _showAddFollowUpDialog() async {
    final actionController = TextEditingController();
    final picController = TextEditingController();
    final notesController = TextEditingController();

    final bool? shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tindak Lanjut'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actionController,
                decoration: const InputDecoration(labelText: 'Tindakan yang Dilakukan'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: picController,
                decoration: const InputDecoration(labelText: 'Penanggung Jawab (PIC)'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Catatan (Opsional)'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (actionController.text.trim().isNotEmpty && picController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Tindakan dan PIC harus diisi!'), backgroundColor: Colors.orange),
                 );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );

    if (shouldAdd == true) {
       setState(() => _isLoadingAction = true);
       try {
          final newAction = {
            'date': DateTime.now().toIso8601String(),
            'action': actionController.text.trim(),
            'person_in_charge': picController.text.trim(),
            'notes': notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
          };

          bool success = await _supabaseService.addFollowUpAction(_currentReport.id!, newAction);

          if (success && mounted) {
            final updatedActions = List<Map<String, dynamic>>.from(_currentReport.followUpActions ?? []);
            updatedActions.add(newAction);

            setState(() {
              _currentReport = _currentReport.copyWith(followUpActions: updatedActions);
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tindak lanjut berhasil ditambahkan'), backgroundColor: Colors.green),
              );
            });
          } else if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Gagal menambahkan tindak lanjut'), backgroundColor: Colors.red),
             );
          }

       } catch (e) {
          if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
       } finally {
          if (mounted) {
            setState(() => _isLoadingAction = false);
          }
       }
    }

    actionController.dispose();
    picController.dispose();
    notesController.dispose();
  }

  // Fungsi untuk menampilkan dialog tutup laporan
  Future<void> _showCloseDialog() async {
    final notesController = TextEditingController();

    final bool? shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutup Laporan Ini?'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Catatan Penutupan (opsional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Tutup Laporan'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (shouldClose == true) {
      setState(() => _isLoadingAction = true);
      try {
        // Gunakan nama pengguna yang login sebagai penutup
        String closedByName = _authService.currentUserDisplayName;
        String? notes = notesController.text.trim().isNotEmpty ? notesController.text.trim() : null;

        bool success = await _supabaseService.closeReport(_currentReport.id!, closedByName, notes);

        if (success && mounted) {
          setState(() {
            _currentReport = _currentReport.copyWith(
              status: 'completed',
              closedBy: closedByName,
              closingNotes: notes,
              closedAt: DateTime.now(),
            );
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Laporan berhasil ditutup'), backgroundColor: Colors.green),
            );
          });
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Gagal menutup laporan'), backgroundColor: Colors.red),
           );
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
      } finally {
         if (mounted) {
          setState(() => _isLoadingAction = false);
        }
      }
    }
    notesController.dispose();
  }

  // Fungsi untuk menampilkan dialog ubah prioritas
  Future<void> _showPriorityDialog() async {
    String? selectedPriority = _currentReport.priority ?? 'Sedang'; // Ambil nilai saat ini

    final String? newPriority = await showDialog<String>( // Ubah tipe return dialog
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar radio button di dalam dialog bisa update state
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Prioritas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Rendah', 'Sedang', 'Tinggi'].map((p) {
                  return RadioListTile<String>(
                    title: Text(p),
                    value: p,
                    groupValue: selectedPriority,
                    onChanged: (value) => setDialogState(() => selectedPriority = value),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), // Return null jika batal
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedPriority), // Return nilai terpilih
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newPriority != null) { // Hanya proses jika user memilih dan menekan Simpan
      setState(() => _isLoadingAction = true);
      try {
        bool success = await _supabaseService.updateReportPriority(_currentReport.id!, newPriority);
        if (success && mounted) {
          setState(() {
            _currentReport = _currentReport.copyWith(priority: newPriority);
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Prioritas diubah menjadi $newPriority'), backgroundColor: Colors.green),
            );
          });
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Gagal mengubah prioritas'), backgroundColor: Colors.red),
           );
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
      } finally {
         if (mounted) {
          setState(() => _isLoadingAction = false);
        }
      }
    }
  }

  // Fungsi untuk menampilkan dialog ubah batas waktu
  Future<void> _showDueDateDialog() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentReport.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)), // Bisa atur tanggal mundur?
      lastDate: DateTime.now().add(const Duration(days: 365)), // Maksimal 1 tahun ke depan
      locale: const Locale('id', 'ID'),
    );

    if (pickedDate != null) {
       setState(() => _isLoadingAction = true);
       try {
          bool success = await _supabaseService.updateReportDueDate(_currentReport.id!, pickedDate);
           if (success && mounted) {
            setState(() {
              _currentReport = _currentReport.copyWith(dueDate: pickedDate);
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Batas waktu diubah menjadi ${_formatNullableDate(pickedDate, 'dd MMM yyyy')}'), backgroundColor: Colors.green),
              );
            });
          } else if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Gagal mengubah batas waktu'), backgroundColor: Colors.red),
             );
          }
       } catch (e) {
          if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
           );
         }
       } finally {
          if (mounted) {
            setState(() => _isLoadingAction = false);
          }
       }
    }
  }


  // Helper widget untuk membuat Card informasi
  Widget _buildInfoCard({required ThemeData theme, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 1, // Sedikit elevasi
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan gambar dengan border radius
  // Placeholder untuk tombol aksi
  Widget _buildWorkflowActions(ThemeData theme) {
    // Tampilkan tombol berdasarkan status laporan saat ini (_currentReport.status)
    // Contoh sederhana:
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: [
          // Tombol Validasi
          if (_currentReport.status == 'submitted' && _currentReport.validationStatus == 'Pending') // Tampilkan jika belum divalidasi
            ElevatedButton.icon(
              onPressed: _isLoadingAction ? null : _showValidateDialog, // Panggil _showValidateDialog
              icon: _isLoadingAction && _currentReport.status == 'submitted' // Tampilkan loading
                  ? _buildLoadingIndicatorSmall()
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Validasi'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),

          // Tombol Tugaskan
          // Logika: Bisa ditugaskan jika sudah valid atau masih submitted (tergantung alur)
          if (_currentReport.status == 'validated' || _currentReport.status == 'submitted')
             ElevatedButton.icon(
              onPressed: _isLoadingAction ? null : _showAssignDialog, // Panggil _showAssignDialog
              icon: _isLoadingAction && (_currentReport.status == 'validated' || _currentReport.status == 'submitted') // Tampilkan loading
                  ? _buildLoadingIndicatorSmall()
                  : const Icon(Icons.assignment_ind_outlined),
              label: const Text('Tugaskan'),
            ),

          // Tombol Tambah Tindak Lanjut
           if (_currentReport.status == 'in_progress')
             ElevatedButton.icon(
              onPressed: _isLoadingAction ? null : _showAddFollowUpDialog, // Panggil _showAddFollowUpDialog
              icon: _isLoadingAction && _currentReport.status == 'in_progress' // Tampilkan loading
                  ? _buildLoadingIndicatorSmall()
                  : const Icon(Icons.add_comment_outlined),
              label: const Text('Tambah TL'),
            ),

           // Tombol Tutup Laporan
           if (_currentReport.status == 'in_progress')
             ElevatedButton.icon(
              onPressed: _isLoadingAction ? null : _showCloseDialog, // Panggil _showCloseDialog
              icon: _isLoadingAction && _currentReport.status == 'in_progress' // Tampilkan loading
                  ? _buildLoadingIndicatorSmall()
                  : const Icon(Icons.lock_outline),
              label: const Text('Tutup Laporan'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
            ),

           // Tombol Ubah Prioritas/Due Date
           if (_currentReport.status != 'completed') ...[
              OutlinedButton.icon(
                onPressed: _isLoadingAction ? null : _showPriorityDialog, // Panggil _showPriorityDialog
                icon: _isLoadingAction ? _buildLoadingIndicatorSmall(color: theme.primaryColor) : const Icon(Icons.priority_high),
                label: const Text('Prioritas'),
              ),
              OutlinedButton.icon(
                onPressed: _isLoadingAction ? null : _showDueDateDialog, // Panggil _showDueDateDialog
                icon: _isLoadingAction ? _buildLoadingIndicatorSmall(color: theme.primaryColor) : const Icon(Icons.edit_calendar_outlined),
                label: const Text('Batas Waktu'),
              ),
           ]
        ],
      ),
    );
  }

  // Widget untuk menampilkan riwayat tindak lanjut
  Widget _buildFollowUpHistory(ThemeData theme) {
    // Handle kasus _currentReport.followUpActions null
    final actions = _currentReport.followUpActions ?? [];
    if (actions.isEmpty) {
       return const SizedBox.shrink(); // Jangan tampilkan apa-apa jika kosong
    }

    final DateFormat historyDateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return ListView.builder(
      shrinkWrap: true, // Agar ListView tidak mengambil tinggi tak terbatas di dalam Column
      physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal ListView
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        DateTime? actionDate;
        try {
          // Pastikan 'date' adalah string sebelum parsing
          if (action['date'] is String) {
             actionDate = DateTime.parse(action['date']);
          }
        } catch (_) {} // Tangani jika parsing gagal

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Container(
             padding: const EdgeInsets.all(12.0),
             decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
             ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      action['person_in_charge']?.toString() ?? 'PIC Tidak Diketahui', // Handle null
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      actionDate != null ? historyDateFormat.format(actionDate) : 'Tanggal?',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(action['action']?.toString() ?? 'Aksi tidak dijelaskan', style: theme.textTheme.bodyMedium), // Handle null
                if (action['notes'] != null && action['notes'].toString().isNotEmpty) ...[ // Handle null dan cek isNotEmpty
                  const SizedBox(height: 4),
                  Text('Catatan: ${action['notes']}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                ]
              ],
            ),
          ),
        );
      },
    );
  }


  // Helper untuk loading indicator kecil di tombol (dengan opsi warna)
  Widget _buildLoadingIndicatorSmall({Color color = Colors.white}) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 8), // Beri jarak jika perlu
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color, // Gunakan warna parameter
      ),
    );
  }


  // Widget untuk menampilkan gambar dengan border radius
  Widget _buildImageSection(BuildContext context, ThemeData theme) {
    // Padding horizontal untuk gambar
    const double horizontalPadding = 16.0;
    // Tinggi gambar
    const double imageHeight = 220.0;

    Widget imageContent;

    // Gunakan _currentReport
    if (_currentReport.imagePath == null || _currentReport.imagePath!.trim().isEmpty) {
      // Placeholder jika tidak ada gambar
      imageContent = Container(
        height: imageHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12), // Border radius
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 60, // Lebih besar
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak Ada Gambar',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Tampilkan gambar jika ada
      imageContent = ClipRRect( // Gunakan ClipRRect untuk border radius
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          _currentReport.imagePath!, // Gunakan _currentReport
          height: imageHeight,
          width: double.infinity, // Lebar penuh
          fit: BoxFit.cover, // Agar gambar mengisi area
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container( // Container untuk background saat loading
              height: imageHeight,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 3.0, // Sedikit lebih tebal
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Error loading image ${_currentReport.imagePath}: $error"); // Gunakan _currentReport
            return Container( // Container untuk background saat error
              height: imageHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded, // Ikon error
                      size: 60,
                      color: theme.colorScheme.error.withOpacity(0.7),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Gagal Memuat Gambar',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // Beri padding horizontal pada gambar
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: imageContent,
    );
  }
}
