# Konfigurasi Proguard untuk Aplikasi LSB OCR

# Aturan untuk Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Aturan untuk model data, hindari obfuscation pada model
-keep class com.example.lsb_ocr.models.** { *; }

# Supabase
-keep class io.supabase.** { *; }
-keep class com.github.supabase.** { *; }

# Http dan Networking Libraries
-keep class com.google.gson.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Obfuscation untuk class konfigurasi API
-keepattributes SourceFile,LineNumberTable
-keep class com.example.lsb_ocr.config.SupabaseConfig { 
    private *; 
    static <fields>; 
}

# Enkripsi nama kelas yang menangani API
-obfuscate class com.example.lsb_ocr.services.**
-optimizations !code/allocation/variable 