# Panduan Visual Setup Supabase untuk LSB OCR

Panduan ini memberikan petunjuk visual tentang cara mengatur storage bucket dan policy di Supabase untuk aplikasi LSB OCR.

## 1. Membuat Storage Bucket

### Langkah 1: Buka bagian Storage
Dari dashboard Supabase, klik menu "Storage" di sidebar kiri.

![Storage Menu](https://i.imgur.com/Fq3nWJj.png)

### Langkah 2: Buat bucket baru
Klik tombol "New Bucket" atau "Create a new bucket".

![Create Bucket](https://i.imgur.com/MRoSO0L.png)

### Langkah 3: Isi detail bucket
- Masukkan nama bucket: `hazard-images`
- Aktifkan "Public bucket" untuk akses publik
- Klik "Create bucket"

![Bucket Details](https://i.imgur.com/Q7oVxXd.png)

## 2. Mengatur RLS Policy untuk Storage

### Langkah 1: Pilih bucket yang baru dibuat
Klik pada bucket `hazard-images` yang baru dibuat.

### Langkah 2: Buka tab Policies
Klik tab "Policies" untuk mengatur RLS.

![Bucket Policies](https://i.imgur.com/3uXEyTn.png)

### Langkah 3: Buat policy untuk SELECT
- Klik "New Policy"
- Pilih "Create policy from scratch"
- Isi:
  - Name: `Allow public access`
  - Operations: SELECT
  - Policy definition: `true`
- Klik "Save policy"

![Select Policy](https://i.imgur.com/tN2WiOQ.png)

### Langkah 4: Buat policy untuk INSERT
- Klik "New Policy" lagi
- Isi:
  - Name: `Allow anonymous uploads`
  - Operations: INSERT
  - Policy definition: `true`
- Klik "Save policy"

![Insert Policy](https://i.imgur.com/X9nz9fV.png)

## 3. Mengatur RLS Policy untuk Tabel hazard_reports

### Langkah 1: Buka Table Editor
Dari dashboard, klik "Table Editor" di sidebar.

![Table Editor](https://i.imgur.com/bJQdwlf.png)

### Langkah 2: Pilih tabel hazard_reports
Klik pada tabel `hazard_reports`.

### Langkah 3: Buka tab Policies
Klik tab "Policies" untuk mengatur RLS.

![Table Policies](https://i.imgur.com/mFU0wE3.png)

### Langkah 4: Buat policy untuk SELECT, INSERT, dan UPDATE
Untuk setiap operasi, ikuti langkah-langkah:
- Klik "New Policy"
- Pilih "Create policy from scratch"
- Isi:
  - Name: `Allow anonymous select/insert/update` (sesuai operasi)
  - Operations: Pilih operasi yang sesuai
  - Policy definition: `true`
- Klik "Save policy"

![Table Policy](https://i.imgur.com/oYKdJfU.png)

## 4. Menggunakan SQL Editor (Alternatif)

Jika Anda lebih suka menggunakan SQL, buka SQL Editor dari sidebar dan jalankan script di file `public_rls_setup.sql`.

![SQL Editor](https://i.imgur.com/d2bDZDJ.png)

## 5. Verifikasi Pengaturan

Setelah semua policy diatur, Anda dapat memverifikasi bahwa:

1. Bucket `hazard-images` sudah dibuat dan memiliki policy SELECT dan INSERT
2. Tabel `hazard_reports` memiliki policy SELECT, INSERT, dan UPDATE

## 6. Jalankan Aplikasi

Sekarang jalankan aplikasi dan coba:
1. Upload gambar
2. Simpan laporan baru
3. Lihat daftar laporan

Jika semua berhasil, Anda telah berhasil mengatur Supabase untuk LSB OCR! 