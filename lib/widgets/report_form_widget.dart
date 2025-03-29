import 'package:flutter/material.dart';
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
    Key? key,
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
  }) : super(key: key);

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Laporan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

        // Tanggal Laporan
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tanggal Laporan',
              hintText: 'Pilih tanggal laporan',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Jenis Pengamatan
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jenis Pengamatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'Unsafe Condition',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: 'Unsafe Condition',
                    groupValue: widget.selectedObservationType,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onObservationTypeChanged(value);
                      }
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text(
                      'Unsafe Action',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: 'Unsafe Action',
                    groupValue: widget.selectedObservationType,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onObservationTypeChanged(value);
                      }
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            RadioListTile<String>(
              title: const Text('Intervensi', style: TextStyle(fontSize: 14)),
              value: 'Intervensi',
              groupValue: widget.selectedObservationType,
              onChanged: (value) {
                if (value != null) {
                  widget.onObservationTypeChanged(value);
                }
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
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

        // Nomor LSB
        TextFormField(
          controller: widget.lsbNumberController,
          decoration: const InputDecoration(
            labelText: 'Nomor LSB',
            hintText: 'Masukkan nomor LSB (opsional)',
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        const SizedBox(height: 16),

        // Tombol Submit
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                widget.isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'KIRIM LAPORAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }
}
