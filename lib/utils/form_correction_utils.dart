import 'package:flutter/material.dart';

class FormCorrectionUtils {
  /// Menampilkan dialog ketika ada koreksi otomatis
  /// dari proses OCR dan analisis AI
  static void showCorrectionReport(
    BuildContext context,
    String correctionReport,
  ) {
    // Format koreksi report menjadi lebih rapi dan mudah dibaca
    final formattedReport = _formatCorrectionReport(correctionReport);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Perbaikan Teks Otomatis',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sistem telah mendeteksi dan memperbaiki beberapa teks otomatis:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCorrectionList(formattedReport),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Silakan periksa data di form untuk memastikan semua perbaikan sudah benar.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber.shade800,
                ),
                child: const Text(
                  'MENGERTI',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  /// Memformat koreksi report menjadi bentuk yang lebih rapi
  static String _formatCorrectionReport(String report) {
    if (report.isEmpty) return "Tidak ada koreksi yang dilakukan.";

    // Hapus format yang tidak diinginkan
    String cleanReport = report
        .replaceAll(RegExp(r'^\s*-\s*'), '') // Hapus bullet di awal
        .replaceAll(RegExp(r'\n\s*-\s*'), '\n'); // Hapus bullet di tengah

    return cleanReport;
  }

  /// Membangun widget untuk menampilkan list koreksi secara rapi
  static Widget _buildCorrectionList(String formattedReport) {
    final lines =
        formattedReport
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

    if (lines.isEmpty) {
      return const Text("Tidak ada koreksi yang dilakukan.");
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lines.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final line = lines[index];

        // Coba deteksi format "teks asli" → "teks perbaikan" : "alasan"
        final parts = _parseCorrection(line);

        if (parts != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: parts['original'] ?? '',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.red,
                              ),
                            ),
                            const TextSpan(text: ' → '),
                            TextSpan(
                              text: parts['corrected'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (parts['reason'] != null && parts['reason']!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text(
                      parts['reason']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          // Fallback jika format tidak terdeteksi
          return ListTile(
            leading: const Icon(Icons.auto_fix_high, size: 16),
            dense: true,
            title: Text(line),
            contentPadding: EdgeInsets.zero,
          );
        }
      },
    );
  }

  /// Memecah string koreksi menjadi teks asli, teks koreksi, dan alasan
  static Map<String, String>? _parseCorrection(String line) {
    // Coba parse dengan format "(asli)" → "(koreksi)" : "(alasan)"
    final regex = RegExp(r'"([^"]+)"\s*→\s*"([^"]+)"(?:\s*:\s*"([^"]+)")?');
    final match = regex.firstMatch(line);

    if (match != null) {
      return {
        'original': match.group(1) ?? '',
        'corrected': match.group(2) ?? '',
        'reason': match.group(3) ?? '',
      };
    }

    // Coba parse format alternatif jika ada
    final altRegex = RegExp(r'([^→]+)→\s*([^:]+)(?:\s*:\s*(.+))?');
    final altMatch = altRegex.firstMatch(line);

    if (altMatch != null) {
      return {
        'original': altMatch.group(1)?.trim() ?? '',
        'corrected': altMatch.group(2)?.trim() ?? '',
        'reason': altMatch.group(3)?.trim() ?? '',
      };
    }

    return null;
  }

  /// Menampilkan dialog error saat proses gagal
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Error'),
              ],
            ),
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
