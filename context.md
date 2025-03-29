context.md yang berisi deskripsi proyek, alur kerja, struktur data, dan contoh kode konseptual untuk aplikasi Laporan Sumber Bahaya (LSB) menggunakan Flutter, Google Cloud Vision, AI (misalnya Gemini API), dan Supabase. Ini dirancang agar bisa diproses oleh AI seperti Cursor AI untuk membantu pembuatan kode.

Markdown

# Context: Aplikasi Laporan Sumber Bahaya (LSB) Otomatis

## 1. Tujuan Utama

Membangun aplikasi mobile (Flutter) yang memungkinkan pekerja di lapangan untuk:
1.  Mengambil foto formulir Laporan Sumber Bahaya (LSB) yang ditulis tangan.
2.  Mengirim foto tersebut ke backend untuk diproses.
3.  Secara otomatis mengekstrak teks dari gambar menggunakan Google Cloud Vision OCR.
4.  Menggunakan AI (misalnya, Google Gemini API) untuk menginterpretasi teks hasil OCR, merapikannya, dan menstrukturkannya sesuai field yang ada di formulir.
5.  Menyimpan data terstruktur tersebut ke database Supabase.

Tujuannya adalah menyederhanakan proses pelaporan LSB bagi pekerja dan admin HSE, mengatasi kendala upload manual ke website perusahaan karena tim proyek yang overload.

## 2. Teknologi yang Digunakan

* **Frontend:** Flutter (Dart)
* **OCR:** Google Cloud Vision API (Text Detection / Document Text Detection)
* **AI Data Structuring:** Google Gemini API (atau LLM lain yang sesuai)
* **Backend & Database:** Supabase (PostgreSQL, Authentication, Storage, Edge Functions - jika diperlukan)
* **Image Input:** Kamera perangkat atau galeri.

## 3. Analisis Formulir LSB (Berdasarkan Gambar)

Gambar `WhatsApp Image 2025-03-25 at 15.22.09.jpeg` menunjukkan formulir LSB dengan field berikut yang perlu diekstrak dan diproses:

* **NAMA PELAPOR:** Teks (Contoh: Tubagus Aang Awaladin)
* **POSISI / JABATAN:** Teks (Contoh: Harian)
* **LOKASI KEJADIAN:** Teks (Contoh: Raden Saleh Shaf ES / 1.1)
* **TANGGAL / WAKTU:** Tanggal/Waktu (Contoh: 10-3-2025) -> Perlu parsing ke format standar (misal: YYYY-MM-DD).
* **JENIS PENGAMATAN:** Pilihan (Unsafe Condition, Unsafe Action, Intervensi) -> Perlu deteksi mana yang ditandai/dicentang. (Contoh: Unsafe Condition)
* **URAIAN PENGAMATAN BAHAYA:** Teks Panjang (Contoh: Pagar Plu kakinya Pada bengkok)
* **TINDAKAN INTERVENSI / SARAN PERBAIKAN:** Teks Panjang (Contoh: Harus diperbaiki takut Robuh atau diperkuat)

**Field Statis/Tidak Diekstrak dari Input Pekerja:**
* No. Dokumen, No. Revisi, Tgl. Berlaku (Sudah terisi di form)
* No. LSB (Diisi oleh HSE Proyek nanti)
* Tanda Tangan Pelapor & Penerima (Tidak diekstrak sebagai data utama, mungkin foto disimpan sebagai bukti)

## 4. Struktur Data (Tabel Supabase)

Disarankan membuat tabel di Supabase, misalnya `hazard_reports`:

```sql
CREATE TABLE hazard_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  reporter_name TEXT,
  reporter_position TEXT,
  location TEXT,
  report_datetime TIMESTAMPTZ, -- Atau DATE jika waktu tidak terlalu penting
  observation_type TEXT, -- Bisa juga ENUM('Unsafe Condition', 'Unsafe Action', 'Intervensi')
  hazard_description TEXT,
  suggested_action TEXT,
  image_path TEXT, -- Path/URL gambar asli di Supabase Storage (opsional)
  status TEXT DEFAULT 'submitted', -- Misal: 'submitted', 'reviewed', 'processed', 'closed'
  lsb_number TEXT -- Diisi oleh HSE nanti
);

-- Aktifkan Row Level Security (Penting!)
ALTER TABLE hazard_reports ENABLE ROW LEVEL SECURITY;

-- Contoh Policy (Sesuaikan kebutuhan):
-- Memungkinkan pengguna terautentikasi untuk memasukkan data
CREATE POLICY "Allow insert for authenticated users" ON hazard_reports
  FOR INSERT TO authenticated WITH CHECK (true);

-- Memungkinkan pengguna melihat data yang mereka submit (jika perlu)
-- CREATE POLICY "Allow individual select access" ON hazard_reports
--   FOR SELECT USING (auth.uid() = user_id); -- Asumsi ada kolom user_id

-- Memungkinkan admin (misal role 'hse') melihat semua data
CREATE POLICY "Allow admin select access" ON hazard_reports
  FOR SELECT TO authenticated USING (get_my_claim('user_role') = '"hse"'); -- Contoh jika pakai custom claims

-- Memungkinkan admin (misal role 'hse') mengupdate data (misal status atau No. LSB)
CREATE POLICY "Allow admin update access" ON hazard_reports
  FOR UPDATE TO authenticated USING (get_my_claim('user_role') = '"hse"');
Tambahkan juga Supabase Storage untuk menyimpan gambar asli jika diperlukan.

5. Alur Kerja Aplikasi
Flutter App (User Interface):

Tampilan utama dengan tombol "Laporkan Bahaya Baru".
Tombol akan membuka kamera atau galeri (image_picker).
Setelah gambar dipilih/diambil, tampilkan preview gambar.
Tombol "Kirim Laporan".
Tampilkan indikator loading saat proses berjalan.
Tampilkan pesan sukses atau error setelah proses selesai.
Flutter App (Logic):

Saat "Kirim Laporan" ditekan:
Konversi gambar ke format yang sesuai (misal: base64 string).
Kirim data gambar ke backend (bisa via Supabase Edge Function atau API endpoint terpisah).
Tunggu respons dari backend.
Backend (Supabase Edge Function / Cloud Function):

Menerima data gambar (base64).
Panggil Google Cloud Vision API:
Kirim gambar ke endpoint Vision API (TEXT_DETECTION atau DOCUMENT_TEXT_DETECTION).
Dapatkan hasil OCR berupa blok teks dan koordinatnya.
Siapkan Prompt untuk AI (Gemini API):
Gabungkan semua teks hasil OCR.
Buat prompt yang jelas, instruksikan AI untuk:
Mengidentifikasi dan mengekstrak nilai untuk setiap field LSB (Nama Pelapor, Posisi, Lokasi, Tanggal, Jenis Pengamatan, Uraian, Saran).
Menginterpretasi tanggal ke format standar (YYYY-MM-DD).
Menentukan Jenis Pengamatan berdasarkan tanda (misal: cari kata kunci dekat checkbox yang ditandai).
Mengembalikan hasil dalam format JSON yang terstruktur.
Contoh Prompt:
Berikut adalah teks hasil OCR dari formulir Laporan Sumber Bahaya:
"{TEKS_HASIL_OCR_DI_SINI}"

Tugas Anda adalah mengekstrak informasi dari teks tersebut dan mengembalikannya dalam format JSON. Identifikasi nilai untuk field berikut:
- reporter_name (Nama Pelapor)
- reporter_position (Posisi / Jabatan)
- location (Lokasi Kejadian)
- report_date (Tanggal / Waktu, format sebagai YYYY-MM-DD)
- observation_type (Pilih salah satu dari: 'Unsafe Condition', 'Unsafe Action', 'Intervensi', berdasarkan mana yang terlihat ditandai atau dipilih)
- hazard_description (Uraian Pengamatan Bahaya)
- suggested_action (Tindakan Intervensi / Saran Perbaikan)

Jika suatu field tidak ditemukan atau tidak jelas, gunakan null untuk nilainya. Pastikan format outputnya adalah JSON yang valid.
Panggil AI API (Gemini):
Kirim prompt ke Gemini API.
Dapatkan respons JSON dari AI.
Parse JSON dan Validasi:
Parse JSON hasil dari AI.
Lakukan validasi dasar (misal: cek format tanggal).
(Opsional) Simpan Gambar Asli:
Decode base64 image.
Upload gambar ke Supabase Storage. Dapatkan path/URL gambar.
Simpan ke Database Supabase:
Gunakan Supabase client library untuk memasukkan data terstruktur (hasil AI) dan path gambar (jika ada) ke tabel hazard_reports.
Kirim Respons:
Kirim status sukses atau pesan error kembali ke aplikasi Flutter.
6. Struktur Kode Flutter (Saran)
lib/
|-- main.dart             # Entry point aplikasi
|-- screens/              # Widget untuk setiap layar
|   |-- home_screen.dart
|   |-- report_form_screen.dart # Layar untuk ambil/preview gambar & kirim
|   |-- success_screen.dart     # Layar konfirmasi sukses
|-- services/             # Logika bisnis & interaksi API
|   |-- supabase_service.dart # Interaksi dengan Supabase (Auth, DB, Functions)
|   |-- report_service.dart   # Fungsi untuk mengirim laporan (panggil backend)
|-- models/               # Model data (misal: HazardReport)
|   |-- hazard_report.dart
|-- widgets/              # Widget UI yang reusable
|   |-- image_input.dart    # Widget untuk memilih/mengambil gambar
|-- utils/                # Fungsi utilitas (misal: formatting tanggal)
|-- config/               # Konfigurasi (API keys, Supabase URL - JANGAN HARDCODE!)
7. Kode Konseptual (Placeholder)
Flutter - Mengirim Gambar (misal di report_service.dart)

Dart

import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http; // Atau pakai package Supabase Functions invoke

class ReportService {
  final supabase = Supabase.instance.client;

  Future<bool> submitHazardReport(File imageFile) async {
    try {
      // 1. Konversi gambar ke base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Panggil Supabase Edge Function (contoh nama function: 'process-hazard-report')
      // Pastikan function ini sudah di-deploy di Supabase
      final response = await supabase.functions.invoke(
        'process-hazard-report',
        body: {'image_base64': base64Image},
      );

      if (response.status == 200 || response.status == 201) {
        // Berhasil diproses oleh backend
        print('Laporan berhasil diproses dan disimpan.');
        return true;
      } else {
        // Ada error dari backend function
        print('Error dari backend: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error saat mengirim laporan: $e');
      return false;
    }
  }
}
Backend - Supabase Edge Function (Typescript - supabase/functions/process-hazard-report/index.ts)

TypeScript

import { serve } from '[https://deno.land/std@0.177.0/http/server.ts](https://www.google.com/search?q=https://deno.land/std%400.177.0/http/server.ts)'
import { createClient } from '[https://esm.sh/@supabase/supabase-js@2](https://www.google.com/search?q=https://esm.sh/%40supabase/supabase-js%402)'
import { GoogleAuth } from 'npm:google-auth-library' // Perlu setup auth Google Cloud
import { DiscussServiceClient } from 'npm:@google-ai/generativelanguage' // Gemini Client

// --- Konfigurasi (Gunakan Environment Variables!) ---
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
// Kredensial Google Cloud (bisa via file JSON atau service account)
const googleCloudProjectId = Deno.env.get('GOOGLE_CLOUD_PROJECT_ID')!
const googleApiKey = Deno.env.get('GOOGLE_API_KEY')! // Untuk Gemini
const visionApiEndpoint = `https://vision.googleapis.com/v1/images:annotate?key=${Deno.env.get('GOOGLE_VISION_API_KEY')!}`; // API Key Vision

// --- Fungsi Utama ---
serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  try {
    const { image_base64 } = await req.json();
    if (!image_base64) {
      return new Response('Missing image_base64 in request body', { status: 400 });
    }

    // 1. Panggil Google Cloud Vision API
    const visionRequest = {
      requests: [
        {
          image: { content: image_base64 },
          features: [{ type: 'DOCUMENT_TEXT_DETECTION' }], // Atau TEXT_DETECTION
        },
      ],
    };

    const visionResponse = await fetch(visionApiEndpoint, {
      method: 'POST',
      body: JSON.stringify(visionRequest),
      headers: { 'Content-Type': 'application/json' },
    });

    if (!visionResponse.ok) {
      console.error('Vision API Error:', await visionResponse.text());
      throw new Error(`Vision API request failed: ${visionResponse.status}`);
    }

    const visionResult = await visionResponse.json();
    const fullText = visionResult.responses?.[0]?.fullTextAnnotation?.text || '';

    if (!fullText) {
      console.warn('OCR did not detect any text.');
      // Bisa handle error ini atau coba lanjutkan dengan teks kosong
      // return new Response('No text detected in image', { status: 400 });
    }

     // 2. Panggil AI (Gemini) untuk structuring
    const MODEL_NAME = "models/gemini-1.5-flash-latest"; // Atau model lain
    const client = new DiscussServiceClient({ authClient: new GoogleAuth().fromAPIKey(googleApiKey) });

    const prompt = `
      Berikut adalah teks hasil OCR dari formulir Laporan Sumber Bahaya:
      "${fullText}"

      Tugas Anda adalah mengekstrak informasi dari teks tersebut dan mengembalikannya dalam format JSON. Identifikasi nilai untuk field berikut:
      - reporter_name (Nama Pelapor)
      - reporter_position (Posisi / Jabatan)
      - location (Lokasi Kejadian)
      - report_date (Tanggal / Waktu, format sebagai YYYY-MM-DD)
      - observation_type (Pilih salah satu dari: 'Unsafe Condition', 'Unsafe Action', 'Intervensi', berdasarkan mana yang terlihat ditandai atau dipilih)
      - hazard_description (Uraian Pengamatan Bahaya)
      - suggested_action (Tindakan Intervensi / Saran Perbaikan)

      Jika suatu field tidak ditemukan atau tidak jelas, gunakan null untuk nilainya.
      Pastikan format outputnya adalah JSON yang valid dan hanya JSON saja tanpa teks tambahan. Contoh:
      {
        "reporter_name": "Nama",
        "reporter_position": "Posisi",
        "location": "Lokasi",
        "report_date": "YYYY-MM-DD",
        "observation_type": "Unsafe Condition",
        "hazard_description": "Deskripsi...",
        "suggested_action": "Saran..."
      }
    `;

    const geminiResult = await client.generateMessage({
        model: MODEL_NAME,
        prompt: { messages: [{ content: prompt }] },
    });

    // Ekstrak JSON dari respons Gemini (mungkin perlu parsing lebih cermat)
    let structuredDataJson = geminiResult[0]?.candidates?.[0]?.content;
    if (!structuredDataJson || typeof structuredDataJson !== 'string') {
         throw new Error('Failed to get valid response content from Gemini.');
    }

    // Bersihkan jika ada markdown code block
    structuredDataJson = structuredDataJson.replace(/^```json\n?/, '').replace(/\n?```$/, '');

    let structuredData;
    try {
        structuredData = JSON.parse(structuredDataJson);
    } catch (parseError) {
        console.error("Failed to parse JSON from AI:", structuredDataJson, parseError);
        throw new Error('AI response was not valid JSON.');
    }


    // 3. (Opsional) Simpan Gambar ke Supabase Storage
    // const imageBuffer = Uint8Array.from(atob(image_base64), c => c.charCodeAt(0));
    // const imagePath = `hazard_reports/${Date.now()}_${Math.random().toString(36).substring(7)}.jpg`;
    // const { error: storageError } = await supabaseAdmin.storage
    //   .from('hazard-images') // Nama bucket
    //   .upload(imagePath, imageBuffer, { contentType: 'image/jpeg' });
    // if (storageError) throw storageError;


    // 4. Simpan Data ke Tabel Supabase
    // Gunakan Service Role Key untuk bypass RLS di backend function
    const supabaseAdmin = createClient(supabaseUrl, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

    const { data, error: insertError } = await supabaseAdmin
      .from('hazard_reports')
      .insert([{
        reporter_name: structuredData.reporter_name,
        reporter_position: structuredData.reporter_position,
        location: structuredData.location,
        report_datetime: structuredData.report_date, // Pastikan format tanggal sesuai kolom DB
        observation_type: structuredData.observation_type,
        hazard_description: structuredData.hazard_description,
        suggested_action: structuredData.suggested_action,
        // image_path: imagePath, // Jika menyimpan gambar
      }])
      .select(); // Select untuk mendapatkan data yg baru diinsert (opsional)


    if (insertError) {
      console.error('Supabase Insert Error:', insertError);
      throw insertError;
    }

    console.log('Successfully inserted:', data);
    return new Response(JSON.stringify({ success: true, data: data }), {
      headers: { 'Content-Type': 'application/json' },
      status: 201,
    });

  } catch (error) {
    console.error('Overall Error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
})

Catatan: Kode Edge Function di atas adalah contoh konseptual. Perlu penyesuaian untuk error handling yang robust, autentikasi Google Cloud, parsing respons AI yang lebih cermat, dan penanganan format tanggal.

8. Kebutuhan Setup & Konfigurasi
Google Cloud Platform:
Buat Proyek GCP.
Aktifkan Cloud Vision API.
Buat API Key untuk Vision API.
Aktifkan Generative Language API (untuk Gemini).
Buat API Key untuk Gemini API.
(Direkomendasikan) Siapkan Service Account untuk autentikasi dari backend jika tidak menggunakan API Key secara langsung.
Supabase:
Buat Proyek Supabase.
Dapatkan URL Proyek dan anon key.
Dapatkan service_role key (untuk digunakan di backend function, JANGAN diekspos ke client).
Buat tabel hazard_reports seperti skema di atas.
(Opsional) Buat Bucket Storage (misal: hazard-images) dan atur policies-nya.
Deploy Supabase Edge Function (process-hazard-report) dengan kode backend di atas (setelah disesuaikan). Atur environment variables di Supabase Function (SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, GOOGLE_VISION_API_KEY, GOOGLE_API_KEY (Gemini), GOOGLE_CLOUD_PROJECT_ID).
Flutter:
Setup Flutter environment.
Tambahkan dependencies di pubspec.yaml:
image_picker
supabase_flutter
http (jika tidak invoke function langsung)
flutter_dotenv (untuk mengelola API keys/URL dengan aman, jangan hardcode!)
Inisialisasi Supabase di main.dart.
Simpan konfigurasi Supabase (URL, Anon Key) dan mungkin nama Edge Function di file environment (.env).
9. Pertimbangan Tambahan
Error Handling: Implementasikan penanganan error yang baik di setiap langkah (pengambilan gambar, pemanggilan API, parsing data, penyimpanan DB). Beri feedback yang jelas ke pengguna.
Keamanan: JANGAN menyimpan API keys atau service role keys langsung di kode Flutter. Gunakan environment variables (via flutter_dotenv) untuk kunci sisi klien (Supabase anon key) dan environment variables di backend (Supabase Edge Function / Cloud Function) untuk kunci sensitif (Vision API Key, Gemini API Key, Supabase Service Role Key). Atur Row Level Security (RLS) di Supabase dengan benar.
Prompt Engineering: Kualitas ekstraksi data oleh AI sangat bergantung pada prompt. Mungkin perlu iterasi untuk menyempurnakan prompt agar AI dapat menangani variasi tulisan tangan dan potensi kesalahan OCR. Pertimbangkan untuk memberikan contoh dalam prompt (few-shot prompting).
Biaya: Perhatikan model biaya Google Cloud Vision API, Gemini API, dan Supabase (terutama terkait pemanggilan function, storage, dan database usage).
User Experience (UX): Berikan indikator loading yang jelas. Jika AI memerlukan waktu untuk memproses, informasikan pengguna. Pertimbangkan untuk menampilkan data yang diekstrak kepada pengguna untuk konfirmasi sebelum benar-benar mengirim ke database (opsional, menambah kompleksitas).
Offline Handling: Jika diperlukan, pertimbangkan menyimpan laporan secara lokal saat tidak ada koneksi dan mengirimkannya nanti saat online.

Semoga `context.md` ini memberikan panduan yang cukup detail bagi Cursor AI untuk membantu Anda membangun aplikasi LSB ini. Ingatlah bahwa kode yang dihasilkan mungkin memerlukan penyesuaian dan pengujian lebih lanjut.

Sources and related content
WhatsApp I...t 15.22.09

JPG