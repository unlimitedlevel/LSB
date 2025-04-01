import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hazard_report.dart';

class SupabaseService {
  final SupabaseClient? _client;

  SupabaseService() : _client = _getSupabaseClient();

  static SupabaseClient? _getSupabaseClient() {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Error getting Supabase client: $e');
      return null;
    }
  }

  // Fungsi untuk memeriksa dan membuat tabel jika belum ada
  Future<bool> createTableIfNotExists() async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Cek apakah tabel hazard_reports sudah ada
      await _client.from('hazard_reports').select('id').limit(1).maybeSingle();

      // Jika berhasil query, berarti tabel sudah ada
      return true;
    } catch (e) {
      debugPrint('Error checking table: $e');
      return false; // Tabel tidak ditemukan atau error lainnya
    }
  }

  // Fungsi untuk mendapatkan laporan bahaya dengan filter dan sorting
  Future<List<HazardReport>> getHazardReports({
    String? statusFilter,
    // Tambahkan parameter filter/sort lain di sini nanti
    // String? priorityFilter,
    // String? assignedToFilter,
    // String? sortBy = 'created_at',
    // bool ascending = false,
  }) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Tentukan tipe awal query builder yang lebih umum jika memungkinkan,
      // atau bangun query secara bertahap.
      dynamic queryBuilder = _client.from('hazard_reports').select(); // Mulai dengan select

      // Terapkan filter jika ada
      if (statusFilter != null && statusFilter != 'Semua') {
        queryBuilder = queryBuilder.eq('status', statusFilter.toLowerCase()); // Tipe berubah menjadi PostgrestFilterBuilder
      }
      // TODO: Tambahkan filter lain di sini (misal: .eq('priority', priorityFilter))

      // Terapkan order di akhir. Metode .order() tersedia di kedua tipe builder.
      queryBuilder = queryBuilder.order('created_at', ascending: false);

      // Eksekusi query
      final response = await queryBuilder;

      // Proses response
      return (response as List)
          .map((item) => HazardReport.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting hazard reports: $e');
      throw Exception('Gagal mendapatkan data laporan dari Supabase: $e');
    }
  }

  /// Menyimpan laporan hazard baru ke Supabase dan mengembalikan response
  Future<Map<String, dynamic>> saveHazardReport(HazardReport report) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      // Konversi model ke JSON. Field baru sudah termasuk di toJson()
      final dataToSave = report.toJson();

      // Hapus field yang mungkin tidak ingin disimpan saat insert awal (jika ada)
      // Contoh: hapus ID jika sudah ada (meskipun toJson sudah menghandle)
      dataToSave.remove('id');
      // Hapus field koreksi AI dari kolom utama jika disimpan di metadata
      // (toJson sudah menghandle ini, tapi bisa eksplisit jika perlu)
      // dataToSave.remove('correction_detected');
      // dataToSave.remove('correction_report');

      // Pastikan metadata untuk koreksi AI ditambahkan jika ada
      // (toJson sudah menghandle ini, tapi bisa eksplisit jika perlu)
      // if (report.correctionDetected == true || report.correctionReport != null) {
      //   dataToSave['metadata'] ??= {};
      //   dataToSave['metadata']['correction_detected'] = report.correctionDetected;
      //   if (report.correctionReport != null) {
      //     dataToSave['metadata']['correction_report'] = report.correctionReport;
      //   }
      // }

      // Set nilai default untuk field workflow saat insert
      dataToSave['status'] ??= 'submitted';
      dataToSave['validation_status'] ??= 'Pending';
      dataToSave['priority'] ??= 'Sedang'; // Default priority

      // Simpan ke Supabase
      final response =
          await _client
              .from('hazard_reports')
              .insert(dataToSave)
              .select()
              .single();

      debugPrint('Hazard report saved successfully: ${response['id']}');
      return response;
    } catch (e) {
      debugPrint('Error saving hazard report: $e');
      throw Exception('Gagal menyimpan laporan ke Supabase: $e');
    }
  }

  // Fungsi untuk mengupdate laporan bahaya
  Future<HazardReport?> updateHazardReport(HazardReport report) async {
    if (_client == null || report.id == null) {
      throw Exception('Supabase client tidak tersedia atau ID laporan kosong');
    }

    try {
      // Konversi model ke JSON. Field baru sudah termasuk.
      final dataToUpdate = report.toJson();

      // Hapus field yang tidak seharusnya diupdate secara langsung atau tidak ada di tabel
      dataToUpdate.remove('id'); // ID tidak diupdate, digunakan di .eq()
      dataToUpdate.remove('created_at'); // created_at biasanya tidak diupdate
      // Hapus field koreksi AI jika disimpan di metadata
      // dataToUpdate.remove('correction_detected');
      // dataToUpdate.remove('correction_report');

      // Pastikan metadata untuk koreksi AI ditambahkan jika ada
      // (toJson sudah menghandle ini)

      // Lakukan update
      final response =
          await _client
              .from('hazard_reports')
              .update(dataToUpdate) // Gunakan dataToUpdate
              .eq('id', report.id!)
              .select()
              .single();

      return HazardReport.fromJson(response);
    } catch (e) {
      debugPrint('Error updating hazard report: $e');
      throw Exception('Gagal mengupdate laporan di Supabase: $e');
    }
  }

  // Fungsi untuk menghapus laporan bahaya
  Future<bool> deleteHazardReport(String id) async {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    try {
      await _client.from('hazard_reports').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting hazard report: $e');
      throw Exception('Gagal menghapus laporan dari Supabase: $e');
    }
  }

  // Membuat URL untuk upload gambar
  String getImageUploadUrl(String path) {
    if (_client == null) {
      throw Exception('Supabase client tidak tersedia');
    }

    // Membuat URL storage Supabase yang benar
    final url = _client.storage.from('hazard-images').getPublicUrl(path);
    return url;
  }

  // --- STUB FUNGSI WORKFLOW ---

  /// Menugaskan laporan ke pengguna lain (implementasi menyusul)
  Future<bool> assignReport(String reportId, String userId, String userName) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Assigning report $reportId to $userName ($userId)');
    try {
      // Data yang akan diupdate
      final updateData = {
        'assigned_to_user_id': userId,
        'assigned_to_name': userName,
        'status': 'in_progress', // Asumsi status berubah menjadi 'in_progress' setelah ditugaskan
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Lakukan update ke Supabase
      await _client
          .from('hazard_reports')
          .update(updateData)
          .eq('id', reportId);

      debugPrint('Report $reportId assigned to $userName successfully.');
      return true; // Berhasil
    } catch (e) {
      debugPrint('Error assigning report $reportId: $e');
      throw Exception('Gagal menugaskan laporan di Supabase: $e');
    }
  }

  /// Memvalidasi laporan (implementasi menyusul)
  Future<bool> validateReport(String reportId, String validationStatus, String validatorName, String? notes) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Validating report $reportId with status: $validationStatus by $validatorName');
    try {
      // Tentukan status utama berdasarkan hasil validasi
      final String newMainStatus = validationStatus == 'Valid' ? 'validated' : 'submitted'; // Kembali ke submitted jika invalid? Atau status 'rejected'?

      // Data yang akan diupdate
      final updateData = {
        'validation_status': validationStatus,
        'validated_by': validatorName,
        'validated_at': DateTime.now().toIso8601String(),
        'validation_notes': notes,
        'status': newMainStatus, // Update status utama juga
        'updated_at': DateTime.now().toIso8601String(), // Selalu update timestamp
      };

      // Hapus notes jika null agar tidak menimpa kolom dengan null
      if (notes == null) {
        updateData.remove('validation_notes');
      }

      // Lakukan update ke Supabase
      await _client
          .from('hazard_reports')
          .update(updateData)
          .eq('id', reportId);

      debugPrint('Report $reportId validation status updated successfully.');
      return true; // Berhasil
    } catch (e) {
      debugPrint('Error validating report $reportId: $e');
      throw Exception('Gagal memvalidasi laporan di Supabase: $e');
    }
  }

  /// Menambahkan aksi tindak lanjut (implementasi menyusul)
  Future<bool> addFollowUpAction(String reportId, Map<String, dynamic> action) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Adding follow up action to report $reportId: ${action['action']}');
    try {
      // 1. Ambil data follow_up_actions yang ada
      final currentData = await _client
          .from('hazard_reports')
          .select('follow_up_actions')
          .eq('id', reportId)
          .single();

      // 2. Siapkan list actions (handle jika null atau bukan list)
      List<Map<String, dynamic>> updatedActions = [];
      if (currentData['follow_up_actions'] is List) {
         updatedActions = List<Map<String, dynamic>>.from(currentData['follow_up_actions']);
      }

      // 3. Tambahkan action baru
      updatedActions.add(action);

      // 4. Update kolom follow_up_actions dengan list yang sudah diperbarui
      await _client
          .from('hazard_reports')
          .update({
            'follow_up_actions': updatedActions,
            'updated_at': DateTime.now().toIso8601String(), // Update timestamp
           })
          .eq('id', reportId);

      debugPrint('Follow up action added successfully for report $reportId.');
      return true; // Berhasil
    } catch (e) {
       debugPrint('Error adding follow up action for report $reportId: $e');
       throw Exception('Gagal menambahkan tindak lanjut di Supabase: $e');
    }
  }

  /// Menutup laporan (implementasi menyusul)
  Future<bool> closeReport(String reportId, String closedBy, String? notes) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Closing report $reportId by $closedBy');
    try {
      // Data yang akan diupdate
      final updateData = {
        'status': 'completed', // Set status utama
        'closed_by': closedBy,
        'closed_at': DateTime.now().toIso8601String(),
        'closing_notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Hapus notes jika null
      if (notes == null) {
        updateData.remove('closing_notes');
      }

      // Lakukan update ke Supabase
      await _client
          .from('hazard_reports')
          .update(updateData)
          .eq('id', reportId);

      debugPrint('Report $reportId closed successfully.');
      return true; // Berhasil
    } catch (e) {
      debugPrint('Error closing report $reportId: $e');
      throw Exception('Gagal menutup laporan di Supabase: $e');
    }
  }

  /// Mengubah prioritas laporan (implementasi menyusul)
  Future<bool> updateReportPriority(String reportId, String priority) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Updating priority for report $reportId to $priority');
     try {
      await _client
          .from('hazard_reports')
          .update({
            'priority': priority,
            'updated_at': DateTime.now().toIso8601String(),
            })
          .eq('id', reportId);
      debugPrint('Report $reportId priority updated successfully.');
      return true;
    } catch (e) {
      debugPrint('Error updating priority for report $reportId: $e');
      throw Exception('Gagal memperbarui prioritas laporan di Supabase: $e');
    }
  }

   /// Mengubah batas waktu laporan (implementasi menyusul)
  Future<bool> updateReportDueDate(String reportId, DateTime dueDate) async {
    if (_client == null) throw Exception('Supabase client tidak tersedia');
    debugPrint('Updating due date for report $reportId to ${dueDate.toIso8601String()}');
     try {
      await _client
          .from('hazard_reports')
          .update({
            'due_date': dueDate.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            })
          .eq('id', reportId);
      debugPrint('Report $reportId due date updated successfully.');
      return true;
    } catch (e) {
      debugPrint('Error updating due date for report $reportId: $e');
      throw Exception('Gagal memperbarui batas waktu laporan di Supabase: $e');
    }
  }

}
