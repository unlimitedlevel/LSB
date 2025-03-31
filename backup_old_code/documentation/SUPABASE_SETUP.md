# Panduan Setup Supabase untuk LSB OCR

Panduan ini menjelaskan langkah-langkah untuk mengatur database Supabase untuk aplikasi LSB OCR berdasarkan format FM-RLSB (Register LSB) R-0.1.

## Langkah 1: Siapkan Project Supabase

1. Login ke [dashboard Supabase](https://app.supabase.com)
2. Buat project baru atau gunakan project yang sudah ada
3. Catat URL Supabase dan Anon Key dari halaman Settings > API

## Langkah 2: Setup Database

### 2.1 Menggunakan Schema SQL

1. Buka tab SQL Editor di Supabase
2. Paste dan jalankan SQL dari file `supabase_schema.sql` 
3. Pastikan tabel `hazard_reports` dan view `lsb_register` berhasil dibuat

### 2.2 Setup Storage Bucket

1. Buka tab Storage di Supabase
2. Buat bucket baru dengan nama `hazard-images`
3. Atur permission sesuai kebutuhan:
   - Siapa saja: Public read, authenticated write
   - Hanya pengguna terautentikasi: Auth read, auth write

## Langkah 3: Konfigurasi Aplikasi

1. Update file `.env` dengan informasi Supabase:
   ```
   SUPABASE_URL=https://[PROJECT_ID].supabase.co
   SUPABASE_ANON_KEY=[YOUR_ANON_KEY]
   POSTGRES_PASSWORD=[YOUR_POSTGRES_PASSWORD]
   ```

2. Pastikan connection pooling dikonfigurasi dengan benar di dashboard Supabase:
   - Host: aws-0-ap-southeast-1.pooler.supabase.com
   - Port: 5432 (direct), 6543 (pooling)
   - Database: postgres
   - User: postgres.[PROJECT_ID]
   - Password: [PostgreSQL password]
   - Pool mode: Session

## Langkah 4: Prisma ORM Setup (Optional)

Jika menggunakan Prisma ORM, pastikan variabel lingkungan berikut dikonfigurasi:

```
DATABASE_URL=postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true
DIRECT_URL=postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres
```

Dan prisma schema:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}

model HazardReport {
  id               String    @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  createdAt        DateTime  @default(now()) @map("created_at") @db.Timestamptz
  updatedAt        DateTime? @map("updated_at") @db.Timestamptz
  
  reporterName     String    @map("reporter_name")
  reporterPosition String    @map("reporter_position")
  reporterSignature String?  @map("reporter_signature")
  
  lsbNumber        String?   @map("lsb_number")
  reportDatetime   DateTime  @map("report_datetime") @db.Timestamptz
  location         String
  observationType  String    @map("observation_type")
  hazardDescription String   @map("hazard_description")
  suggestedAction  String    @map("suggested_action")
  
  status           String    @default("submitted")
  imagePath        String?   @map("image_path")
  
  validatedBy      String?   @map("validated_by")
  validationNotes  String?   @map("validation_notes")
  validatedAt      DateTime? @map("validated_at") @db.Timestamptz
  
  followUp         String?   @map("follow_up")
  followedUpBy     String?   @map("followed_up_by")
  followedUpAt     DateTime? @map("followed_up_at") @db.Timestamptz
  
  closedBy         String?   @map("closed_by")
  closingNotes     String?   @map("closing_notes")
  closedAt         DateTime? @map("closed_at") @db.Timestamptz

  @@map("hazard_reports")
}
```

## Pengujian Koneksi

Untuk menguji koneksi ke database:

1. Update file `.env` dengan kredensial yang benar
2. Jalankan aplikasi
3. Periksa log untuk konfirmasi koneksi berhasil
4. Coba buat laporan baru dan verifikasi data tersimpan di Supabase

## Troubleshooting

- **Error koneksi ke database**: Periksa apakah password dan credential lainnya sudah benar
- **Error storage**: Periksa apakah bucket `hazard-images` sudah dibuat dan policy sudah diatur dengan benar
- **RLS Error**: Periksa kebijakan RLS (Row Level Security) di dashboard Supabase 