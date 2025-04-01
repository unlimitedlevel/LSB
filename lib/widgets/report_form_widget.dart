import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan import intl
import '../config/app_theme.dart';

class ReportFormWidget extends StatefulWidget {
  final TextEditingController reporterNameController;
  final TextEditingController reporterPositionController;
  final TextEditingController locationController;
  final TextEditingController hazardDescriptionController;
  final TextEditingController suggestedActionController;
  final TextEditingController lsbNumberController;
  final DateTime selectedDate;
  final String selectedObservationType;
  final Function(DateTime) onDateSelected;
  final Function(String) onObservationTypeChanged;
  final Function() onSubmit;
  final bool isLoading;

  const ReportFormWidget({
    super.key,
    required this.reporterNameController,
    required this.reporterPositionController,
    required this.locationController,
    required this.hazardDescriptionController,
    required this.suggestedActionController,
    required this.lsbNumberController,
    required this.selectedDate,
    required this.selectedObservationType,
    required this.onDateSelected,
    required this.onObservationTypeChanged,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Judul Bagian Pelapor ---
        Text(
          'Informasi Pelapor',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Nama Pelapor
        TextFormField(
          controller: widget.reporterNameController,
          decoration: const InputDecoration(
            labelText: 'Nama Pelapor',
            hintText: 'Masukkan nama pelapor',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama pelapor harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Jabatan Pelapor
        TextFormField(
          controller: widget.reporterPositionController,
          decoration: const InputDecoration(
            labelText: 'Jabatan/Posisi',
            hintText: 'Masukkan jabatan atau posisi pelapor',
            prefixIcon: Icon(Icons.work),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jabatan/posisi harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // --- Judul Bagian Kejadian ---
        const Divider(height: 32, thickness: 1),
        Text(
          'Detail Kejadian',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Lokasi Bahaya
        TextFormField(
          controller: widget.locationController,
          decoration: const InputDecoration(
            labelText: 'Lokasi Bahaya',
            hintText: 'Masukkan lokasi bahaya dengan spesifik',
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lokasi bahaya harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Tanggal Laporan - Tampilan Lebih Baik
        TextFormField(
          readOnly: true, // Agar tidak bisa diketik manual
          controller: TextEditingController(
            text: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.selectedDate), // Format tanggal lengkap
          ),
          decoration: InputDecoration(
            labelText: 'Tanggal Laporan',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded), // Indikator dropdown
            // Gunakan style dari tema
          ),
          onTap: _selectDate, // Panggil _selectDate saat ditekan
        ),
        const SizedBox(height: 16),

        // Jenis Pengamatan - Layout Lebih Rapi
        Text('Jenis Pengamatan', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        Wrap( // Gunakan Wrap agar fleksibel di berbagai ukuran layar
          spacing: 8.0, // Jarak horizontal antar radio
          runSpacing: 0.0, // Jarak vertikal jika wrap ke baris baru
          children: <String>['Unsafe Condition', 'Unsafe Action', 'Intervensi']
              .map((String value) {
            return Row(
              mainAxisSize: MainAxisSize.min, // Agar Row tidak memanjang penuh
              children: <Widget>[
                Radio<String>(
                  value: value,
                  groupValue: widget.selectedObservationType,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      widget.onObservationTypeChanged(newValue);
                    }
                  },
                  visualDensity: VisualDensity.compact, // Lebih rapat
                ),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // --- Judul Bagian Deskripsi ---
        const Divider(height: 32, thickness: 1),
        Text(
          'Deskripsi & Saran',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Deskripsi Bahaya
        TextFormField(
          controller: widget.hazardDescriptionController,
          decoration: const InputDecoration(
            labelText: 'Deskripsi Bahaya',
            hintText: 'Jelaskan kondisi bahaya secara detail',
            prefixIcon: Icon(Icons.warning),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi bahaya harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Saran Tindakan
        TextFormField(
          controller: widget.suggestedActionController,
          decoration: const InputDecoration(
            labelText: 'Saran Tindakan',
            hintText: 'Berikan saran tindakan untuk mengatasi bahaya',
            prefixIcon: Icon(Icons.build),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Saran tindakan harus diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Nomor LSB (Opsional)
        TextFormField(
          controller: widget.lsbNumberController,
          decoration: const InputDecoration(
            labelText: 'Nomor LSB (Opsional)', // Tambahkan (Opsional)
            hintText: 'Contoh: 001-LSB-XYZ',
            prefixIcon: Icon(Icons.tag), // Ganti ikon
          ),
        ),
        const SizedBox(height: 32), // Spasi lebih besar sebelum tombol

        // Tombol Submit - Style Disesuaikan
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon( // Gunakan ElevatedButton.icon
            onPressed: widget.isLoading ? null : widget.onSubmit,
            icon: widget.isLoading
                ? Container( // Indikator loading dalam tombol
                    width: 24,
                    height: 24,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Icon(Icons.send_rounded), // Ikon kirim
            label: Text(
              widget.isLoading ? 'MENGIRIM...' : 'KIRIM LAPORAN',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16), // Padding vertikal
              textStyle: theme.textTheme.titleMedium, // Ukuran teks
              // Style lain diambil dari tema (primary color, shape)
            ),
          ),
        ),
      ],
    );
  }

  // Fungsi pemilih tanggal
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)), // Batasi hingga besok
      locale: const Locale('id', 'ID'), // Pastikan locale Indonesia
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }
}
