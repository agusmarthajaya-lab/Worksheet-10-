# Worksheet 10 — KosFinder Device Demo (STANDALONE)

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Advanced Mobile Features & Device Integration (Flutter • Camera • GPS • Sensors • Storage)  
**Dosen:** Dr. Ir. I Ketut Resika Arthana, S.T., M.Kom.  
**Teaching Assistant:** Made Yuda Sadewa, S.Pd.  

| Identitas Mahasiswa | Isian |
|---|---|
| **Nama** | I Putu Agus Martha Jaya |
| **NIM** | 2415051097 |
| **Kelas** | 3C |
| **Repository** | https://github.com/agusmarthajaya-lab/Worksheet-10- |

---

## A. Gambaran Umum Project
KosFinder Device Demo adalah aplikasi demonstrasi integrasi fitur perangkat keras tingkat lanjut pada Flutter secara **STANDALONE** (tanpa login, tabel database, role, atau source code Worksheet 9).

Fitur-fitur utama:
1. **Kamera & Galeri (`image_picker`):** Pengguna dapat mengambil foto kamar kos secara langsung melalui kamera atau memilih dari galeri.
2. **Penyimpanan Permanen Lokal (`path_provider` + `shared_preferences`):** File foto dipindahkan secara aman dari direktori cache sementara ke `Application Documents Directory` (`kosfinder_photos`), dan draft metadata disimpan dalam format JSON.
3. **GPS Berkesadaran Izin (`geolocator`):** Mengambil koordinat perangkat dengan penanganan izin runtime (denied, deniedForever, serviceDisabled).
4. **Pengayaan Cloud Storage (`supabase_flutter`):** Mendukung Anonymous Sign-In dan upload foto ke Supabase Storage bucket `kosfinder-demo` dengan Row Level Security (RLS) berbasis folder `auth.uid()`.
5. **Pengayaan Sensor Gerak (`sensors_plus`):** Demonstrasi pembacaan accelerometer `userAccelerometerEventStream` pada sumbu x, y, dan z.

---

## B. Struktur Proyek
```text
lib/
├── cloud_config.dart                  # Konfigurasi Supabase opsional (--dart-define)
├── main.dart                          # Entry point aplikasi & tema Material 3 Teal
├── pages/
│   ├── device_demo_page.dart          # UI utama: input nama, foto, GPS, draft, cloud upload
│   └── sensor_demo_page.dart          # Halaman demo pembacaan sensor accelerometer
└── services/
    ├── draft_repository.dart          # Service simpan/baca draft lokal & permanent photo
    ├── device_location_service.dart   # Service penanganan GPS & runtime permissions
    └── photo_upload_service.dart      # Service upload Supabase via Anonymous Sign-In

platform/
├── android_manifest_snippet.xml       # Snippet permission Android
└── ios_info_plist_snippet.xml         # Snippet usage description iOS

sql/
└── storage_policy.sql                 # Kebijakan RLS folder terisolasi pada Supabase Storage
```

---

## C. Konfigurasi Permission Platform

### 1. Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 2. iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Fitur demo memerlukan kamera untuk memotret kamar kos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Fitur demo memilih foto kamar dari galeri.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Fitur demo menggunakan lokasi untuk mengisi koordinat.</string>
<key>NSMotionUsageDescription</key>
<string>Fitur demo membaca gerakan perangkat untuk belajar sensor.</string>
```

---

## D. Cara Menjalankan Aplikasi

### 1. Mode Lokal / Offline (Tanpa Kredensial Cloud)
```bash
flutter pub get
flutter run
```
Pada mode ini, aplikasi berjalan 100% offline dengan pesan status:  
`Mode: lokal/offline (Supabase belum dikonfigurasi)`.

### 2. Mode Cloud Pengayaan (Supabase Storage)
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

---

## E. Tabel Hasil Pengujian Terstruktur

| No. | Kasus Uji | Skenario | Hasil yang Diharapkan | Status |
|:---:|:---|:---|:---|:---:|
| 1 | Foto via kamera | Tekan tombol Kamera, potret objek | Pratinjau foto tampil; tersalin ke folder dokumen lokal | **BERHASIL** |
| 2 | Foto via galeri | Tekan tombol Galeri, pilih foto JPG/PNG | Foto berhasil dipilih dan pratinjau tampil di UI | **BERHASIL** |
| 3 | Batalkan galeri | Buka galeri lalu tekan tombol Back/Cancel | Aplikasi tetap stabil, draft dan foto sebelumnya tidak hilang | **BERHASIL** |
| 4 | Kamera/galeri tidak diizinkan | Cabut izin kamera/media lewat App Settings | Muncul SnackBar informasi kesalahan; aplikasi tidak crash | **BERHASIL** |
| 5 | GPS diberikan | Tekan Ambil Koordinat GPS dan izinkan | Nilai Latitude & Longitude terisi dan tersimpan otomatis | **BERHASIL** |
| 6 | GPS ditolak | Tolak dialog izin lokasi saat diminta | Pesan kesalahan ramah muncul; foto & draft tetap bisa disimpan | **BERHASIL** |
| 7 | GPS nonaktif | Matikan switch Location perangkat | Muncul pesan error dan tombol shortcut buka pengaturan GPS | **BERHASIL** |
| 8 | Buka ulang aplikasi | Isi data, Simpan Draft, tutup app dari Recent Apps, buka kembali | Nama kos, foto kamar, dan koordinat GPS dipulihkan otomatis | **BERHASIL** |
| 9 | Tanpa internet | Mode Airplane On, lakukan simpan draft lokal | Penyimpanan draft lokal berfungsi lancar tanpa error network | **BERHASIL** |
| 10* | Upload cloud berhasil | Jalankan dengan `--dart-define`, tekan Upload | Objek tersimpan di bucket `kosfinder-demo/<UUID>/` & URL publik tampil | **BERHASIL** |
| 11* | Upload saat offline | Matikan koneksi internet saat upload cloud | Muncul SnackBar gagal upload; draft lokal tetap aman tersimpan | **BERHASIL** |
| 12* | Sensor digerakkan | Buka ikon sensor di AppBar, goyangkan HP | Nilai sumbu x, y, z terupdate secara real-time | **BERHASIL** |

*\* = modul pengayaan opsional.*

---

## F. Jawaban Pertanyaan Praktikum & Refleksi

### 1. Pertanyaan Praktik 2
- **Mengapa foto tidak cukup disimpan sebagai path dari `image_picker` saja?**  
  *Jawaban:* `image_picker` menyimpan foto sementara pada direktori cache OS. File di folder cache dapat dibersihkan kapan saja oleh sistem operasi saat ruang memori minim atau aplikasi ditutup. Foto harus disalin permanen ke `Application Documents Directory` agar tidak hilang ketika aplikasi dibuka kembali.
- **Apa yang terjadi pada draft lokal jika aplikasi di-uninstall atau data aplikasinya dihapus?**  
  *Jawaban:* Seluruh data draft lokal (baik metadata JSON di `SharedPreferences` maupun file gambar di direktori dokumen) akan terhapus secara permanen karena berada di dalam sandbox penyimpanan privat aplikasi.

### 2. Pertanyaan Praktik 3
- **Mengapa aplikasi tidak boleh memaksa pengguna memberikan izin GPS untuk memakai galeri?**  
  *Jawaban:* Berdasarkan prinsip *Graceful Degradation* dan *Separation of Concerns*, fitur foto dan lokasi bersifat independen. Menolak GPS tidak boleh menghambat pengguna untuk mengisi nama kos, mengambil foto, dan menyimpan draft secara lokal.

### 3. Pertanyaan Pengayaan Cloud
- **Mengapa akun anonymous tetap dapat menggunakan policy `to authenticated`?**  
  *Jawaban:* Karena metode `signInAnonymously()` di Supabase Auth membuat session resmi ber-JWT dengan role `authenticated` dan `auth.uid()` unik sementara, sehingga lolos evaluasi policy SQL `to authenticated`.
- **Mengapa tidak boleh mengganti policy dengan `with check (true)` untuk semua pengguna?**  
  *Jawaban:* Policy `with check (true)` membuka celah keamanan serius di mana siapa saja dapat menimpa file pengguna lain, mengunggah konten berbahaya, atau menghabiskan kuota bucket penyimpanan tanpa batasan isolasi hak akses.

### 4. Refleksi Mahasiswa
1. **Mengapa praktik inti sengaja dapat digunakan tanpa backend?**  
   Agar fokus pembelajaran tertuju pada penguasaan interaksi perangkat keras (kamera, GPS, sensor gerak) dan persistensi lokal secara mandiri tanpa terdistraksi konfigurasi server.
2. **Bagaimana perbedaan runtime permission dan Storage RLS?**  
   Runtime permission bekerja di sisi perangkat klien (OS Android/iOS) untuk mengatur hak akses ke sensor dan periferal, sedangkan Storage RLS bekerja di sisi server/database untuk mengatur hak akses read/insert objek file.
3. **Mengapa menyimpan foto langsung di SharedPreferences bukan pendekatan yang baik?**  
   SharedPreferences didesain untuk data primitif ringan (key-value). Menyimpan string gambar (misal Base64) berukuran megabyte akan memboroskan RAM, memperlambat proses startup, dan rentan menimbulkan Out-Of-Memory (OOM).
4. **Bagaimana aplikasi memberi kebebasan pengguna ketika akses GPS ditolak?**  
   Aplikasi menetapkan koordinat sebagai data opsional (bisa bernilai null), tidak mematikan tombol lain, dan memberikan opsi navigasi langsung ke pengaturan sistem jika pengguna berubah pikiran.
5. **Risiko apa yang muncul apabila lokasi/foto pengguna dipublikasikan tanpa konfirmasi?**  
   Dapat membahayakan privasi dan keamanan fisik pemilik kos/pengguna (doxxing), membocorkan titik koordinat privat, serta potensi pelanggaran data pribadi.
