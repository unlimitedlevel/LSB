import 'package:flutter/material.dart';
import '../models/hazard_report.dart';
import 'image_processing_service.dart';

/// Service untuk memproses gambar hazard report dan membangun metadata
class ReportService {
  static final ReportService _instance = ReportService._internal();
  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();

  factory ReportService() {
    return _instance;
  }

  ReportService._internal();

  /// Memproses gambar hazard report dan mengembalikan data hasil ekstraksi
  /// [imageSource] bisa berupa File atau XFile
  Future<Map<String, dynamic>?> processImage(dynamic imageSource) async {
    try {
      // Validasi sumber gambar
      if (imageSource == null) {
        throw Exception('Gambar tidak boleh kosong');
      }

      // Proses gambar menggunakan ImageProcessingService
      final extractedData = await _imageProcessingService
          .processWithGeminiVision(imageSource);

      if (extractedData != null) {
        debugPrint('Extracted data: ${extractedData.keys.join(', ')}');
        return extractedData;
      } else {
        throw Exception('Tidak ada data yang berhasil diekstrak dari gambar');
      }
    } catch (e) {
      debugPrint('Error processing hazard report image: $e');
      // Lempar error ke layer UI untuk ditangani
      throw Exception('Gagal memproses gambar: $e');
    }
  }

  /// Membangun metadata hazard report berdasarkan data yang diekstrak
  HazardReport buildReportMetadata(Map<String, dynamic> extractedData) {
    try {
      // Konversi report_date string ke DateTime
      DateTime reportDatetime = DateTime.now();
      if (extractedData['report_date'] != null) {
        try {
          reportDatetime = DateTime.parse(extractedData['report_date']);
        } catch (e) {
          debugPrint('Error parsing date: ${extractedData['report_date']}');
        }
      }

      // Persiapkan metadata untuk menyimpan informasi tambahan, seperti koreksi typo
      Map<String, dynamic> metadata = {};
      if (extractedData['metadata'] != null) {
        metadata = Map<String, dynamic>.from(extractedData['metadata']);
      }

      return HazardReport(
        reporterName: extractedData['reporter_name'] ?? '',
        reporterPosition: extractedData['reporter_position'] ?? '',
        location: extractedData['location'] ?? '',
        reportDatetime: reportDatetime,
        observationType:
            extractedData['observation_type'] ?? 'Unsafe Condition',
        hazardDescription: extractedData['hazard_description'] ?? '',
        suggestedAction: extractedData['suggested_action'] ?? '',
        status: 'Submitted',
        lsbNumber: extractedData['lsb_number'],
        createdAt: DateTime.now(),
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Error building report metadata: $e');
      throw Exception('Gagal membuat metadata laporan: $e');
    }
  }
}
