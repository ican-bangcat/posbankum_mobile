# Ringkasan Projek POSBANKUM Mobile (Aplikasi Pendamping Hukum)

Dokumen ini berisi gambaran umum arsitektur, integrasi sistem, analisis database, progres pengembangan, serta rencana kerja selanjutnya untuk aplikasi mobile POSBANKUM.

---

## 1. Arsitektur & Teknologi Utama

Projek ini terdiri dari dua sistem utama yang saling terintegrasi secara *real-time*:

*   **Frontend (Aplikasi Mobile):**
    *   **Teknologi:** Flutter (Dart).
    *   **State Management & Routing:** GetX.
    *   **HTTP Client:** Dio (dengan interceptor untuk melampirkan JWT/Bearer token).
    *   **Penyajian Berkas:** Penampil PDF internal (`flutter_pdfview`) dengan pengunduhan aman ke cache lokal ponsel.
*   **Backend (Laravel API):**
    *   **Teknologi:** Laravel 11/10.
    *   **Autentikasi:** Laravel Sanctum (Token Bearer).
    *   **Penyimpanan File:** File fisik di folder privat (`storage/app/lampiran`), diakses secara aman melalui middleware otorisasi.

---

## 2. Hubungan Mobile (`lib/`) dengan Laravel API (`routes/api.php` & Controllers)

Seluruh logika tampilan Flutter di folder `lib/` terhubung langsung dengan endpoint backend di `routes/api.php` dan dikendalikan oleh Controller Laravel di folder `app/Http/Controllers/Api/`:

| Fitur di Aplikasi Mobile | Controller API Laravel | Endpoint Rute API | Keterangan Logika |
| :--- | :--- | :--- | :--- |
| **Auth & Profil** | `AuthController.php`, `ProfileController.php` | `POST /register`<br>`POST /login`<br>`GET /profile`<br>`PUT /profile` | Mengelola data user manual maupun Google OAuth, serta snapshot profil warga (`masyarakat`). |
| **Daftar & Detail Aduan** | `PengaduanController.php` | `GET /pengaduan`<br>`POST /pengaduan`<br>`GET /pengaduan/{id}` | Mengambil data aduan. Pada POV Paralegal, daftar diurutkan berdasarkan skor prioritas (**Priority Queue**). |
| **Klaim & Status Kasus** | `PengaduanController.php` | `PATCH /pengaduan/{id}/status` | Mengubah status kasus (`menunggu` $\rightarrow$ `diproses` $\rightarrow$ `selesai`/`dibatalkan`). Otomatis mencatat `id_paralegal`. |
| **Dokumen Lampiran** | `UploadController.php` | `GET /pengaduan/{id}/lampiran`<br>`GET /pengaduan/{id}/lampiran/{id_lampiran}/view` | Upload bukti awal aduan dan melihat file privat. Backend memverifikasi otorisasi user sebelum menyajikan file fisik. |
| **Riwayat Progres** | `TimelineController.php` | `GET /pengaduan/{id}/timeline`<br>`POST /pengaduan/{id}/timeline` | Log historis tindakan kasus (*immutable*). Tidak memiliki kolom `updated_at`. |
| **Komunikasi / Chat** | `ChatController.php` | `GET /chat/{id}`<br>`POST /chat/{id}` | Komunikasi langsung antara warga pelapor dengan paralegal pendamping per kasus. |
| **Kegiatan Lapangan** | `KegiatanController.php` | `GET /kegiatan`<br>`POST /kegiatan` | Laporan penyuluhan atau aktivitas lapangan hukum yang dibuat oleh paralegal. |

---

## 3. Sinkronisasi Database (`posbankum_db_250626.sql` vs `analisis_database_updated.md`)

Berdasarkan analisis file skema database terbaru [posbankum_db_250626.sql](file:///d:/Semester%206/Proyek%20Akhir/antigravity_posbankum/posbankum_mobile/posbankum_db_250626.sql) and model relasi [analisis_database_updated (1).md](file:///d:/Semester%206/Proyek%20Akhir/antigravity_posbankum/posbankum_mobile/analisis_database_updated%20(1).md):

1.  **Relasi Wilayah Posbankum Dinamis (Sesuai Aturan Dosen):**
    Tabel `pengaduan` **tidak menyimpan** kolom `id_posbankum` atau data wilayah secara langsung untuk menghindari redundansi. Wilayah kerja aduan ditentukan lewat `user_id` pengaju $\rightarrow$ `masyarakat.id_kelurahan` $\rightarrow$ `posbankum.id_kelurahan`.
2.  **Kolom Otoritas Kasus (`id_paralegal`):**
    Kolom `id_paralegal` terdaftar di tabel `pengaduan` sebagai relasi ke tabel `users`. Kolom ini bernilai `NULL` saat aduan baru masuk (`menunggu`), dan terisi `id_user` paralegal yang bersangkutan saat diklaim (`diproses`).
3.  **Tabel `pengaduan_timeline` Tanpa `updated_at`:**
    Sesuai standar industri untuk data log historis (*immutable*), tabel `pengaduan_timeline` hanya memiliki kolom `created_at` dan `tanggal` tanpa `updated_at`. Logika backend Laravel (`TimelineController.php`) telah disesuaikan agar tidak mengirim field `updated_at`.

---

## 4. Hubungan / Integrasi dengan Sistem Web (SIBAPAK)

Aplikasi Web SIBAPAK bertindak sebagai **Pusat Kontrol (Admin Panel)**, sedangkan aplikasi Mobile adalah **Ujung Tombak Operasional Lapangan**. Kaitannya meliputi:

*   **Manajemen Akun & Wilayah Tugas:**
    *   Registrasi akun paralegal dan penugasan wilayah kerja hanya bisa dilakukan oleh Super Admin melalui **Website SIBAPAK** (mencatat data ke tabel `posbankum_paralegal` dengan status `aktif` dan menentukan apakah dia paralegal utama (`is_primary` = 1)).
    *   Akun yang telah dibuat oleh Admin di web inilah yang digunakan oleh paralegal untuk login di aplikasi Mobile.
*   **Validasi Kegiatan Lapangan:**
    *   Paralegal mengunggah laporan penyuluhan atau kegiatan hukum lapangan langsung dari lokasi via **Aplikasi Mobile** (menyimpan data ke tabel `kegiatan`).
    *   Admin di **Website SIBAPAK** dapat melihat rekapitulasi, memvalidasi berkas laporan kegiatan, dan memantau persebaran kegiatan hukum secara administratif.
*   **Rekapitulasi Pengaduan Tingkat Daerah:**
    *   Seluruh pengaduan yang diajukan oleh warga via Mobile terkumpul secara otomatis di dashboard **Website SIBAPAK** untuk keperluan analisis statistik, ekspor laporan berkala ke kementerian hukum, dan rekap penyerapan dana Posbankum.

---

## 5. Progres Projek Sejauh Ini & Rencana Langkah Selanjutnya

### Progres Saat Ini (Progress Report)
*   [x] **Autentikasi & Manajemen Akun (PB01):** Integrasi Login & Register manual, Google OAuth, penyimpanan token sesi (`GetStorage`), dan kerangka dashboard BottomNavigationBar warga.
*   [x] **Pengajuan & Manajemen Pengaduan (PB02-03):** Slicing form pengaduan dinamis (bukti file & PDF), daftar status pengaduan, dan panel dashboard klaim kasus berbasis wilayah kerja prioritas (*Priority Queue*).
*   [x] **Linimasa & Riwayat Penanganan (PB04 - TC-19):** Sinkronisasi log linimasa dinamis dari paralegal ke warga dengan penanganan fallback parsing tanggal serta pembaruan data minim gangguan (*silent reload*) via tarik-segarkan (*pull-to-refresh*).
*   [x] **Unit Testing Komprehensif (PB02-04):** Pembuatan 29 unit/widget test lengkap dengan inisialisasi context `GetMaterialApp` dan advance fake async timers untuk memvalidasi alur bisnis modul pengaduan.
*   [x] **Sistem Pengamanan File Privat:** Penyimpanan privat lokal server, verifikasi otorisasi RBAC (warga pemilik, paralegal sewilayah, admin) di backend, dan pemuatan aman di mobile via header token.
*   [x] **In-App PDF Viewer:** Widget pembaca PDF internal dengan layout yang aman dari tabrakan tombol navigasi sistem Android/iOS.
*   [x] **Pemberantasan Bug Update Status:** Perbaikan error 500 saat "Ambil Kasus" yang disebabkan oleh ketidakcocokan kolom `updated_at` pada tabel `pengaduan_timeline` di server Laravel.
*   [x] **Uji Coba Alur Kasus End-to-End:** Memastikan transisi status berjalan mulus dari dibuat (`menunggu`) $\rightarrow$ diklaim (`diproses` + pencatatan log timeline) $\rightarrow$ penyusunan progres kegiatan $\rightarrow$ diselesaikan secara formal (`selesai` / `dibatalkan` disertai catatan internal penolakan kasus).

### Rencana Selanjutnya (Next Steps)
*   [ ] **Komunikasi & Chat Konsultasi (PB05):** Membuat ruang obrolan/chat room real-time per kasus antara warga dengan paralegal pendamping.
*   [ ] **Notifikasi Sistem (PB06):** Membuat Pusat Notifikasi (Notification Center) aplikasi dan integrasi Push Notification SDK (Firebase Cloud Messaging).
*   [ ] **Laporan Kegiatan Lapangan (PB07):** Pembuatan form laporan kegiatan lapangan paralegal (penyuluhan/sosialisasi) disertai kamera picker dan approval verifikasi admin.
