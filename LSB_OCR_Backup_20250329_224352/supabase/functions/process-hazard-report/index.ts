import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { GoogleAuth } from 'npm:google-auth-library'
import { DiscussServiceClient } from 'npm:@google-ai/generativelanguage'

// --- Konfigurasi (Gunakan Environment Variables!) ---
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
// Kredensial Google Cloud (bisa via file JSON atau service account)
const googleCloudProjectId = Deno.env.get('GOOGLE_CLOUD_PROJECT_ID')!
const googleApiKey = Deno.env.get('GOOGLE_API_KEY')! // Untuk Gemini
const visionApiEndpoint = `https://vision.googleapis.com/v1/images:annotate?key=${Deno.env.get('GOOGLE_VISION_API_KEY')!}`;

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
      return new Response('No text detected in image', { status: 400 });
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

    // Ekstrak JSON dari respons Gemini
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
}); 