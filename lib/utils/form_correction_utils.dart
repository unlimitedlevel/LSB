import 'package:flutter/material.dart';

class FormCorrectionUtils {
  /// Menampilkan dialog ketika ada koreksi otomatis 
  /// dari proses OCR dan analisis AI
  static void showCorrectionReport(
    BuildContext context, 
    String correctionReport
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text('Perbaikan Teks Otomatis'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sistem telah mendeteksi dan memperbaiki beberapa teks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(correctionReport),
            const SizedBox(height: 16),
            const Text(
              'Silakan periksa data di form untuk memastikan kebenaran.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MENGERTI'),
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog error saat proses gagal
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Mengekstrak data dari response AI
  static Map<String, dynamic> parseExtractedData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    // Ekstrak field-field standar
    final possibleFields = [
      'reporter_name',
      'reporter_position',
      'location',
      'report_date',
      'observation_type',
      'hazard_description',
      'suggested_action',
      'lsb_number',
    ];
    
    for (final field in possibleFields) {
      if (data.containsKey(field) && data[field] != null) {
        result[field] = data[field];
      }
    }
    
    // Tambahkan metadata jika ada
    if (data.containsKey('metadata')) {
      result['metadata'] = data['metadata'];
    }
    
    return result;
  }
} 