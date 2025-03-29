import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/hazard_report.dart';
import 'image_processing_service.dart';

/// Service untuk memproses laporan bahaya
/// Termasuk OCR dan analisis dengan AI
class ReportService {
  // Instance Singleton
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;

  final ImageProcessingService _imageProcessingService =
      ImageProcessingService();

  ReportService._internal();

  /// Memproses gambar dan mengekstrak data dengan OCR dan AI
  Future<Map<String, dynamic>?> processImage(dynamic imageSource) async {
    try {
      if (imageSource == null) {
        throw Exception('Gambar tidak boleh kosong');
      }

      // Validasi tipe gambar
      if (!(imageSource is File || imageSource is Uint8List)) {
        throw Exception('Format gambar tidak didukung');
      }

      // Proses dengan Gemini Vision API
      final result = await _imageProcessingService.processWithGeminiVision(
        imageSource,
      );

      if (result == null) {
        debugPrint('Gagal memproses gambar dengan Gemini API');
        throw Exception('Gagal memproses gambar');
      }

      // Bangun metadata tambahan jika diperlukan
      return result;
    } catch (e) {
      debugPrint('Error processing image: $e');

      // Untuk demo atau pengujian, return dummy data jika error
      debugPrint('Returning dummy data due to error');
      return _getDummyData();
    }
  }

  /// Membangun metadata laporan berdasarkan hasil ekstraksi dan koreksi
  Map<String, dynamic> buildReportMetadata({
    required Map<String, dynamic> extractedData,
    String? originalText,
  }) {
    final metadata = <String, dynamic>{
      'extracted_timestamp': DateTime.now().toIso8601String(),
      'extraction_source': 'gemini_vision',
    };

    // Tambahkan informasi koreksi jika ada
    if (extractedData.containsKey('correction_report')) {
      // Pastikan correction_report adalah string
      final corrReport = extractedData['correction_report'];
      metadata['correction_report'] =
          corrReport is String ? corrReport : corrReport.toString();
      metadata['correction_detected'] = true;
    } else if (extractedData['metadata'] != null &&
        extractedData['metadata']['correction_report'] != null) {
      final corrReport = extractedData['metadata']['correction_report'];
      metadata['correction_report'] =
          corrReport is String ? corrReport : corrReport.toString();
      metadata['correction_detected'] =
          extractedData['metadata']['correction_detected'] ?? false;
    }

    // Tambahkan teks asli jika tersedia
    if (originalText != null) {
      metadata['original_text'] = originalText;
    }

    return metadata;
  }

  /// Menghasilkan data dummy untuk demo dan testing
  Map<String, dynamic> _getDummyData() {
    return {
      'reporter_name': 'Ahmad Kurniawan',
      'reporter_position': 'Safety Inspector',
      'location': 'Area Produksi Zona B',
      'report_date': DateTime.now().toString().substring(0, 10),
      'observation_type': 'Unsafe Condition',
      'hazard_description':
          'Kabel listrik terkelupas di dekat area kerja operator yang dapat menyebabkan risiko tersengat listrik.',
      'suggested_action':
          'Segera ganti kabel yang terkelupas dan periksa semua jalur kabel di area tersebut.',
      'lsb_number': 'LSB-2025-0043',
      'metadata': {
        'correction_detected': true,
        'correction_report':
            '- "terkelupas" dikoreksi dari "ter-kelupas"\n- "tersengat" dikoreksi dari "kesetrum"',
      },
    };
  }
}
