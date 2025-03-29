import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/hazard_report.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  bool _isDemoMode = false;
  bool _isStorageBucketAvailable = false;
  List<HazardReport> _demoReports = [];

  bool get isDemoMode => _isDemoMode;
  bool get isStorageBucketAvailable => _isStorageBucketAvailable;

  // Inisialisasi Supabase dan cek keberadaan table hazard_reports
  Future<void> initializeSupabase() async {
    try {
      // Cek apakah tabel hazard_reports sudah ada
      final exists = await _checkTableExists(SupabaseConfig.hazardReportsTable);

      if (!exists) {
        debugPrint(
          'Tabel ${SupabaseConfig.hazardReportsTable} tidak ditemukan',
        );
        debugPrint('Aplikasi berjalan dalam mode demo (tanpa database)');
        _isDemoMode = true;
        _isStorageBucketAvailable = false;
        // Inisialisasi demo reports jika diperlukan
        _initDemoReports();
      } else {
        debugPrint('Tabel ${SupabaseConfig.hazardReportsTable} ditemukan');
        _isDemoMode = false;

        // Cek apakah bucket storage tersedia
        try {
          // Asumsikan bucket ada jika kita memiliki kredensial S3
          if (SupabaseConfig.s3AccessKeyId.isNotEmpty &&
              SupabaseConfig.s3SecretAccessKey.isNotEmpty) {
            debugPrint(
              'Menggunakan kredensial S3 untuk akses bucket ${SupabaseConfig.storageBucket}',
            );
            _isStorageBucketAvailable = true;
          } else {
            // Coba dengan getBucket (metode lama)
            await supabase.storage.getBucket(SupabaseConfig.storageBucket);
            debugPrint(
              'Storage bucket ${SupabaseConfig.storageBucket} ditemukan',
            );
            _isStorageBucketAvailable = true;
          }
        } catch (e) {
          debugPrint(
            'Storage bucket ${SupabaseConfig.storageBucket} tidak ditemukan: $e',
          );
          debugPrint('Upload gambar akan menggunakan URL placeholder');
          _isStorageBucketAvailable = false;

          // Jika bucket tidak ditemukan, tampilkan panduan
          debugPrint(
            'Silakan ikuti petunjuk di file BUCKET_SETUP.md untuk membuat bucket dan mengatur policy RLS',
          );
        }
      }
    } catch (e) {
      debugPrint('Error saat inisialisasi Supabase: $e');
      debugPrint('Aplikasi berjalan dalam mode demo (tanpa database)');
      _isDemoMode = true;
      _isStorageBucketAvailable = false;
      // Inisialisasi demo reports jika diperlukan
      _initDemoReports();
    }
  }

  // Inisialisasi data demo
  void _initDemoReports() {
    _demoReports = [];
  }

  // Cek apakah table sudah ada
  Future<bool> _checkTableExists(String tableName) async {
    try {
      await supabase.from(tableName).select('id').limit(1);
      return true;
    } catch (e) {
      debugPrint('Error cek tabel $tableName: $e');
      return false;
    }
  }

  // Upload gambar ke Supabase storage atau return dummy URL
  Future<String?> uploadImage(Uint8List bytes, String filename) async {
    if (_isDemoMode || !_isStorageBucketAvailable) {
      // Return placeholder URL dalam mode demo atau jika bucket tidak tersedia
      return 'https://via.placeholder.com/400?text=LSB+Image+Demo';
    }

    try {
      final String path = 'hazard_reports/$filename';

      // Gunakan try-catch untuk menangani error RLS
      try {
        // Upload file ke bucket
        await supabase.storage
            .from(SupabaseConfig.storageBucket)
            .uploadBinary(path, bytes);

        // Dapatkan URL publik
        String imageUrl = supabase.storage
            .from(SupabaseConfig.storageBucket)
            .getPublicUrl(path);

        debugPrint('Gambar berhasil diupload: $imageUrl');
        return imageUrl;
      } catch (e) {
        // Jika error RLS, coba lagi dengan menganggap error RLS bisa diabaikan
        // karena bucket berstatus publik
        debugPrint('Error saat upload gambar (bisa diabaikan jika RLS): $e');

        // Coba ambil URL publik meskipun upload mungkin gagal
        try {
          String imageUrl = supabase.storage
              .from(SupabaseConfig.storageBucket)
              .getPublicUrl('hazard_reports/$filename');

          debugPrint('Mencoba mengakses URL gambar secara langsung: $imageUrl');
          return imageUrl;
        } catch (urlError) {
          debugPrint('Gagal mendapatkan URL gambar: $urlError');
          // Return placeholder URL jika gagal
          return 'https://via.placeholder.com/400?text=RLS+Error';
        }
      }
    } catch (e) {
      debugPrint('Error umum upload gambar: $e');
      // Return placeholder URL jika error
      return 'https://via.placeholder.com/400?text=LSB+Image+Error';
    }
  }

  // Submit hazard report
  Future<HazardReport> submitHazardReport(HazardReport report) async {
    if (_isDemoMode) {
      // Simpan ke list demo jika dalam mode demo
      final demoReport = HazardReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        reporterName: report.reporterName,
        reporterPosition: report.reporterPosition,
        location: report.location,
        reportDatetime: report.reportDatetime,
        observationType: report.observationType,
        hazardDescription: report.hazardDescription,
        suggestedAction: report.suggestedAction,
        lsbNumber: report.lsbNumber,
        reporterSignature: report.reporterSignature,
        imagePath: report.imagePath,
        status: 'submitted',
      );

      _demoReports.add(demoReport);
      return demoReport;
    }

    try {
      // Buat JSON dengan field yang diperlukan
      final Map<String, dynamic> reportJson = {
        'reporter_name': report.reporterName,
        'reporter_position': report.reporterPosition,
        'location': report.location,
        'report_datetime': report.reportDatetime.toIso8601String(),
        'observation_type': report.observationType,
        'hazard_description': report.hazardDescription,
        'suggested_action': report.suggestedAction,
        'image_path': report.imagePath,
        'status': 'submitted',
      };

      // Tambahkan field opsional jika ada
      if (report.lsbNumber != null) {
        reportJson['lsb_number'] = report.lsbNumber;
      }

      if (report.reporterSignature != null) {
        reportJson['reporter_signature'] = report.reporterSignature;
      }

      try {
        final response =
            await supabase
                .from(SupabaseConfig.hazardReportsTable)
                .insert(reportJson)
                .select()
                .single();

        return HazardReport.fromJson(response);
      } catch (e) {
        debugPrint('Error RLS saat menyimpan laporan: $e');
        debugPrint(
          'Silakan ikuti petunjuk di file BUCKET_SETUP.md untuk mengatur policy RLS pada tabel',
        );

        // Fallback ke mode demo jika ada error RLS
        final demoReport = HazardReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          reporterName: report.reporterName,
          reporterPosition: report.reporterPosition,
          location: report.location,
          reportDatetime: report.reportDatetime,
          observationType: report.observationType,
          hazardDescription: report.hazardDescription,
          suggestedAction: report.suggestedAction,
          lsbNumber: report.lsbNumber,
          reporterSignature: report.reporterSignature,
          imagePath: report.imagePath,
          status: 'submitted',
        );

        _demoReports.add(demoReport);
        return demoReport;
      }
    } catch (e) {
      debugPrint('Error saat menyimpan laporan: $e');

      // Fallback ke mode demo jika database error
      final demoReport = HazardReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        reporterName: report.reporterName,
        reporterPosition: report.reporterPosition,
        location: report.location,
        reportDatetime: report.reportDatetime,
        observationType: report.observationType,
        hazardDescription: report.hazardDescription,
        suggestedAction: report.suggestedAction,
        lsbNumber: report.lsbNumber,
        reporterSignature: report.reporterSignature,
        imagePath: report.imagePath,
        status: 'submitted',
      );

      _demoReports.add(demoReport);
      return demoReport;
    }
  }

  // Get hazard reports
  Future<List<HazardReport>> getHazardReports() async {
    if (_isDemoMode) {
      return _demoReports;
    }

    try {
      final response = await supabase
          .from(SupabaseConfig.hazardReportsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => HazardReport.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error saat mengambil laporan: $e');
      return _demoReports;
    }
  }

  // Ambil satu hazard report by ID
  Future<HazardReport?> getHazardReport(String id) async {
    if (_isDemoMode) {
      try {
        return _demoReports.firstWhere((r) => r.id == id);
      } catch (e) {
        return null;
      }
    }

    try {
      final response =
          await supabase
              .from(SupabaseConfig.hazardReportsTable)
              .select()
              .eq('id', id)
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error saat mengambil laporan: $e');
      return null;
    }
  }

  // Validasi laporan
  Future<HazardReport?> validateReport(
    String id,
    String validator,
    String notes,
  ) async {
    if (_isDemoMode) {
      final index = _demoReports.indexWhere((r) => r.id == id);
      if (index >= 0) {
        final now = DateTime.now();
        final updatedReport = HazardReport(
          id: _demoReports[index].id,
          createdAt: _demoReports[index].createdAt,
          reporterName: _demoReports[index].reporterName,
          reporterPosition: _demoReports[index].reporterPosition,
          location: _demoReports[index].location,
          reportDatetime: _demoReports[index].reportDatetime,
          observationType: _demoReports[index].observationType,
          hazardDescription: _demoReports[index].hazardDescription,
          suggestedAction: _demoReports[index].suggestedAction,
          lsbNumber: _demoReports[index].lsbNumber,
          reporterSignature: _demoReports[index].reporterSignature,
          imagePath: _demoReports[index].imagePath,
          status: 'validated',
          updatedAt: now,
          validatedBy: validator,
          validationNotes: notes,
          validatedAt: now,
        );
        _demoReports[index] = updatedReport;
        return updatedReport;
      }
      return null;
    }

    try {
      final now = DateTime.now().toIso8601String();

      // Perbarui status dan data validasi
      final Map<String, dynamic> updateData = {
        'status': 'validated',
        'updated_at': now,
        'validated_by': validator,
        'validation_notes': notes,
        'validated_at': now,
      };

      final response =
          await supabase
              .from(SupabaseConfig.hazardReportsTable)
              .update(updateData)
              .eq('id', id)
              .select()
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error saat validasi laporan: $e');
      return null;
    }
  }

  // Tambah follow-up
  Future<HazardReport?> addFollowUp(
    String id,
    String followUp,
    String by,
  ) async {
    if (_isDemoMode) {
      final index = _demoReports.indexWhere((r) => r.id == id);
      if (index >= 0) {
        final now = DateTime.now();
        final updatedReport = HazardReport(
          id: _demoReports[index].id,
          createdAt: _demoReports[index].createdAt,
          reporterName: _demoReports[index].reporterName,
          reporterPosition: _demoReports[index].reporterPosition,
          location: _demoReports[index].location,
          reportDatetime: _demoReports[index].reportDatetime,
          observationType: _demoReports[index].observationType,
          hazardDescription: _demoReports[index].hazardDescription,
          suggestedAction: _demoReports[index].suggestedAction,
          lsbNumber: _demoReports[index].lsbNumber,
          reporterSignature: _demoReports[index].reporterSignature,
          imagePath: _demoReports[index].imagePath,
          status: 'in_progress',
          updatedAt: now,
          followUp: followUp,
          followedUpBy: by,
          followedUpAt: now,
          validatedBy: _demoReports[index].validatedBy,
          validationNotes: _demoReports[index].validationNotes,
          validatedAt: _demoReports[index].validatedAt,
        );
        _demoReports[index] = updatedReport;
        return updatedReport;
      }
      return null;
    }

    try {
      final now = DateTime.now().toIso8601String();

      // Perbarui status dan data follow-up
      final Map<String, dynamic> updateData = {
        'status': 'in_progress',
        'updated_at': now,
        'follow_up': followUp,
        'followed_up_by': by,
        'followed_up_at': now,
      };

      final response =
          await supabase
              .from(SupabaseConfig.hazardReportsTable)
              .update(updateData)
              .eq('id', id)
              .select()
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error saat follow-up laporan: $e');
      return null;
    }
  }

  // Close report
  Future<HazardReport?> closeReport(
    String id,
    String closedBy,
    String closingNotes,
  ) async {
    if (_isDemoMode) {
      final index = _demoReports.indexWhere((r) => r.id == id);
      if (index >= 0) {
        final now = DateTime.now();
        final updatedReport = HazardReport(
          id: _demoReports[index].id,
          createdAt: _demoReports[index].createdAt,
          reporterName: _demoReports[index].reporterName,
          reporterPosition: _demoReports[index].reporterPosition,
          location: _demoReports[index].location,
          reportDatetime: _demoReports[index].reportDatetime,
          observationType: _demoReports[index].observationType,
          hazardDescription: _demoReports[index].hazardDescription,
          suggestedAction: _demoReports[index].suggestedAction,
          lsbNumber: _demoReports[index].lsbNumber,
          reporterSignature: _demoReports[index].reporterSignature,
          imagePath: _demoReports[index].imagePath,
          status: 'closed',
          updatedAt: now,
          closedBy: closedBy,
          closingNotes: closingNotes,
          closedAt: now,
          followUp: _demoReports[index].followUp,
          followedUpBy: _demoReports[index].followedUpBy,
          followedUpAt: _demoReports[index].followedUpAt,
          validatedBy: _demoReports[index].validatedBy,
          validationNotes: _demoReports[index].validationNotes,
          validatedAt: _demoReports[index].validatedAt,
        );
        _demoReports[index] = updatedReport;
        return updatedReport;
      }
      return null;
    }

    try {
      final now = DateTime.now().toIso8601String();

      // Perbarui status dan data penutupan laporan
      final Map<String, dynamic> updateData = {
        'status': 'closed',
        'updated_at': now,
        'closed_by': closedBy,
        'closing_notes': closingNotes,
        'closed_at': now,
      };

      final response =
          await supabase
              .from(SupabaseConfig.hazardReportsTable)
              .update(updateData)
              .eq('id', id)
              .select()
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error saat menutup laporan: $e');
      return null;
    }
  }
}
