import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/hazard_report.dart';
import '../config/supabase_config.dart';

class ReportService {
  final supabase = Supabase.instance.client;

  Future<HazardReport?> processHazardReportImage(dynamic imageFile) async {
    try {
      late final Uint8List bytes;
      late final String base64Image;

      if (kIsWeb) {
        debugPrint('Memproses gambar untuk web...');
        if (imageFile is XFile) {
          bytes = await imageFile.readAsBytes();
        } else {
          bytes = await imageFile.readAsBytes();
        }
        base64Image = base64Encode(bytes);
      } else {
        if (imageFile is File) {
          bytes = await imageFile.readAsBytes();
        } else if (imageFile is XFile) {
          bytes = await imageFile.readAsBytes();
        } else {
          throw Exception('Format file tidak didukung');
        }
        base64Image = base64Encode(bytes);
      }

      debugPrint('Memulai proses OCR dan analisis dengan Gemini API...');
      return await _processWithGeminiVision(base64Image);
    } catch (e) {
      debugPrint('Error saat memproses gambar laporan: $e');
      return null;
    }
  }

  Future<HazardReport?> _processWithGeminiVision(String base64Image) async {
    try {
      final geminiApiKey = SupabaseConfig.geminiApiKey;
      if (geminiApiKey.isEmpty) {
        throw Exception('Gemini API key tidak tersedia');
      }

      final geminiApiEndpoint =
          'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$geminiApiKey';

      final prompt = '''
Analisis gambar form Laporan Sumber Bahaya (LSB) dengan format FM-LSB dari PT Nindya Karya. 

Berikut informasi yang perlu diekstrak dari form:
1. No. LSB (terletak di bagian atas form)
2. NAMA PELAPOR
3. POSISI/JABATAN
4. LOKASI KEJADIAN
5. TANGGAL/WAKTU
6. JENIS PENGAMATAN (perhatikan tanda centang/check (√) atau (v) di kotak: Unsafe Condition, Unsafe Action, atau Intervensi)
7. URAIAN PENGAMATAN BAHAYA
8. TINDAKAN INTERVENSI/SARAN PERBAIKAN
9. Nama Pelapor (tanda tangan, jika terdeteksi)

Dalam form ini, format tanggal biasanya dd mmmm yyyy (contoh: 12 maret 2025).
Nomor LSB memiliki format seperti "001-lsb-los04" atau sejenisnya.

Berikan output dalam format JSON dengan struktur berikut:
{
  "lsb_number": "(isi dari No. LSB)",
  "reporter_name": "(isi dari NAMA PELAPOR)",
  "reporter_position": "(isi dari POSISI/JABATAN)",
  "location": "(isi dari LOKASI KEJADIAN)",
  "report_date": "(konversi TANGGAL/WAKTU ke format YYYY-MM-DD)",
  "observation_type": "(pilih dari ['Unsafe Condition', 'Unsafe Action', 'Intervensi'] berdasarkan yang dicentang)",
  "hazard_description": "(isi dari URAIAN PENGAMATAN BAHAYA)",
  "suggested_action": "(isi dari TINDAKAN INTERVENSI/SARAN PERBAIKAN)",
  "reporter_signature": "(nama yang tertulis di bagian tanda tangan Pelapor, jika ada)"
}

Pastikan:
1. Ekstrak data PERSIS seperti yang tertulis di form
2. Jangan tambahkan interpretasi
3. Untuk observation_type, periksa tanda centang (✓, √, v, atau X) di form
4. Format tanggal harus YYYY-MM-DD
5. Jika ada field kosong, gunakan string kosong ("")
6. Data ini akan dimasukkan ke dalam database sesuai format FM-RLSB (Register LSB) R-0.1
''';

      debugPrint('Mengirim gambar dan prompt ke Gemini API...');
      final request = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {'temperature': 0.1, 'topK': 1, 'topP': 1},
      };

      final response = await http.post(
        Uri.parse(geminiApiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gemini Vision API error: ${response.statusCode} - ${response.body}',
        );
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final String? content =
          jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (content == null || content.isEmpty) {
        throw Exception('Tidak ada respons yang valid dari Gemini Vision API');
      }

      final String cleanedContent =
          content.replaceAll('```json', '').replaceAll('```', '').trim();

      debugPrint('Hasil analisis Gemini Vision: $cleanedContent');

      final Map<String, dynamic> extractedData = jsonDecode(cleanedContent);

      // Parse tanggal dengan format yang benar
      DateTime reportDate;
      try {
        reportDate = DateTime.parse(extractedData['report_date']);
      } catch (e) {
        debugPrint('Error parsing tanggal: $e');
        reportDate = DateTime.now();
      }

      return HazardReport(
        reporterName: extractedData['reporter_name'] ?? '',
        reporterPosition: extractedData['reporter_position'] ?? '',
        location: extractedData['location'] ?? '',
        reportDatetime: reportDate,
        observationType:
            extractedData['observation_type'] ?? 'Unsafe Condition',
        hazardDescription: extractedData['hazard_description'] ?? '',
        suggestedAction: extractedData['suggested_action'] ?? '',
        lsbNumber: extractedData['lsb_number'] ?? '',
        reporterSignature: extractedData['reporter_signature'] ?? '',
      );
    } catch (e) {
      debugPrint('Error saat menggunakan Gemini Vision API: $e');
      return null;
    }
  }

  Future<HazardReport> submitManualReport(
    HazardReport report, {
    File? imageFile,
  }) async {
    try {
      String? imagePath;

      if (imageFile != null) {
        try {
          if (kIsWeb) {
            imagePath = null;
          } else {
            final bytes = await imageFile.readAsBytes();
            final filename =
                '${DateTime.now().millisecondsSinceEpoch}_${report.reporterName.replaceAll(' ', '_')}.jpg';

            imagePath = await _uploadImage(bytes, filename);
          }
        } catch (e) {
          debugPrint('Error saat upload gambar: $e');
        }
      }

      final updatedReport = HazardReport(
        reporterName: report.reporterName,
        reporterPosition: report.reporterPosition,
        location: report.location,
        reportDatetime: report.reportDatetime,
        observationType: report.observationType,
        hazardDescription: report.hazardDescription,
        suggestedAction: report.suggestedAction,
        lsbNumber: report.lsbNumber,
        reporterSignature: report.reporterSignature,
        imagePath: imagePath,
      );

      try {
        final response =
            await supabase
                .from('hazard_reports')
                .insert(updatedReport.toJson())
                .select()
                .single();

        return HazardReport.fromJson(response);
      } catch (e) {
        debugPrint(
          'Error saat menyimpan ke database, menggunakan mode demo: $e',
        );

        return HazardReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          reporterName: updatedReport.reporterName,
          reporterPosition: updatedReport.reporterPosition,
          location: updatedReport.location,
          reportDatetime: updatedReport.reportDatetime,
          observationType: updatedReport.observationType,
          hazardDescription: updatedReport.hazardDescription,
          suggestedAction: updatedReport.suggestedAction,
          lsbNumber: updatedReport.lsbNumber,
          reporterSignature: updatedReport.reporterSignature,
          imagePath: imagePath,
          status: 'submitted',
        );
      }
    } catch (e) {
      debugPrint('Error saat mengirim laporan: $e');

      return HazardReport(
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
        status: 'submitted',
      );
    }
  }

  Future<String?> _uploadImage(Uint8List bytes, String filename) async {
    try {
      final String path = 'hazard_reports/$filename';
      await supabase.storage.from('hazard-images').uploadBinary(path, bytes);

      final imageUrl = supabase.storage
          .from('hazard-images')
          .getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      debugPrint('Error upload gambar: $e');
      return null;
    }
  }
}
