# Product Backlog POSBANKUM Mobile (Metode Agile UX)

Dokumen ini berisi daftar **Product Backlog** untuk pengembangan aplikasi mobile **POSBANKUM** (Warga & Paralegal). Metode pengerjaan yang diterapkan adalah **Agile UX (Dual-Track Agile)**, di mana tim **UI/UX** dan **Developer Mobile** berkolaborasi secara iteratif. Aktivitas UI/UX (riset, perancangan mockup, dan pengujian kegunaan) berjalan sedikit di depan atau sejajar dengan aktivitas coding (pembuatan tampilan, logika aplikasi, dan koneksi server).

---

## 📖 Kamus Istilah Teknis (Glossary)
Untuk menyamakan pemahaman, berikut penjelasan sederhana istilah teknis yang digunakan dalam backlog ini:
*   **Slicing UI:** Proses mengubah gambar desain (dari Figma/Adobe XD) menjadi kode tampilan nyata (tombol, teks, layout) menggunakan bahasa pemrograman Flutter.
*   **Integrasi API:** Proses menghubungkan aplikasi Flutter dengan server (backend Laravel) agar data bisa saling dikirim (seperti mengirim formulir) dan diterima (seperti mengambil riwayat kasus) secara dinamis dari database.
*   **Google Sign-In SDK:** Alat bantu siap pakai untuk membuat fitur login otomatis menggunakan akun Google.
*   **GetStorage / Secure Storage:** Ruang penyimpanan kecil di memori HP untuk menyimpan data penting seperti data login pengguna agar pengguna tidak perlu login ulang saat membuka aplikasi.
*   **Multipart Request (Upload File):** Metode pengiriman data dari HP ke server yang bisa membawa teks sekaligus berkas fisik (seperti foto JPG atau dokumen PDF).
*   **Priority Queue:** Sistem pengurutan berbasis skala prioritas, di mana kasus yang dinilai paling darurat akan otomatis berada di daftar paling atas.
*   **Polling / WebSocket:** Metode agar pesan chat bisa langsung muncul. *Polling* adalah mengecek pesan ke server setiap beberapa detik sekali, sedangkan *WebSocket* membuat HP dan server terus terhubung langsung tanpa putus.
*   **Push Notification SDK (FCM):** Layanan pembantu agar HP bisa menerima pemberitahuan di bilah status (status bar) meskipun aplikasi sedang ditutup.

---

## 👥 Pembagian Peran & Alur Kerja

*   **Tim UI/UX (Desain & Aset):** 
    *   Merancang alur perjalanan pengguna di aplikasi (*User Flow*).
    *   Membuat sketsa kasar (*Wireframe*) dan desain akhir (*High-Fidelity Mockup*) di Figma.
    *   Mengekspor aset gambar, warna, dan ikon untuk digunakan developer.
    *   Melakukan pengujian prototype interaktif kepada pengguna (*Usability Testing*).
*   **Developer Mobile (Aku - Coding & Pembuatan Logika):**
    *   Membuat tampilan di Flutter (*Slicing UI*) menyontek desain Figma.
    *   Mengatur navigasi perpindahan halaman dan melakukan validasi formulir (misal: cek NIK harus 16 digit).
    *   Menghubungkan aplikasi ke database backend (*Integrasi API*) menggunakan library Dio.
    *   Menangani penyimpanan status masuk (login session) dan penyimpanan file sementara (cache).

---

## 📋 Tabel Product Backlog

| ID Backlog | Fitur / Modul | User Story & Deskripsi | Tugas Tim UI/UX (Desain & Aset) | Tugas Developer Mobile (Coding & Integrasi Server) | Estimasi Sprint |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PB01** | **Autentikasi & Manajemen Akun** | **Warga:**<br>Sebagai Warga, saya ingin mendaftar dan login (manual & Google OAuth) serta melengkapi profil agar data saya tervalidasi saat melakukan pengaduan.<br><br>**Paralegal:**<br>Sebagai Paralegal, saya ingin login dengan akun yang dibuat Admin di web agar dapat masuk ke panel penanganan kasus. | 1. Merancang alur pendaftaran, login, dan pengisian data profil.<br>2. Membuat desain halaman Login & Register (warga).<br>3. Membuat desain halaman Lengkapi Profil Warga (NIK, Alamat, Kelurahan).<br>4. Membuat desain profil menu Paralegal.<br>5. Menyediakan aset tombol Google Sign-In dan ilustrasi pendukung. | 1. Membuat tampilan (*Slicing*) halaman Login, Register, Lengkapi Profil (Warga), dan Profil (Paralegal) di Flutter.<br>2. Menghubungkan halaman Login & Register ke server backend Laravel (`POST /login`, `POST /register`).<br>3. Memasang fitur login menggunakan akun Google (Google Sign-In).<br>4. Menyimpan kode keamanan masuk (Token Bearer) ke penyimpanan lokal HP (`GetStorage`) agar status login tetap aktif.<br>5. Mengatur agar pengguna yang belum login otomatis diarahkan ke halaman login.<br>6. Membuat validasi input pendaftaran (format email valid, NIK wajib 16 digit, kecocokan kolom password). | **Sprint 1** |
| **PB02** | **Pengajuan Pengaduan (POV Warga)** | **Warga:**<br>Sebagai Warga, saya ingin membuat pengaduan dengan mengisi formulir aduan (kronologi, wilayah kejadian, jenis masalah) dan mengunggah bukti awal (gambar/PDF) agar bisa diproses oleh paralegal. | 1. Merancang form input pengaduan (multi-step form atau single form panjang).<br>2. Membuat komponen pemilih berkas (file picker) untuk bukti awal.<br>3. Mendesain layar konfirmasi pengiriman aduan sukses/gagal.<br>4. Mendesain halaman daftar pengaduan aktif milik warga. | 1. Membuat tampilan (*Slicing*) formulir pengaduan, tombol pilih berkas, dan daftar riwayat aduan milik warga.<br>2. Menghubungkan pilihan wilayah kejadian ke server agar daftar kelurahan/kecamatan muncul otomatis.<br>3. Menambahkan fitur pemilih berkas (foto & PDF) dari memori penyimpanan HP.<br>4. Menghubungkan form pengaduan ke server (`POST /pengaduan`) untuk mengirim data teks dan file bukti secara bersamaan (*Multipart Request*).<br>5. Membuat logika agar kolom pelapor otomatis terisi dari data profil warga. | **Sprint 1 & 2** |
| **PB03** | **Manajemen Kasus Masuk (POV Paralegal)** | **Paralegal:**<br>Sebagai Paralegal, saya ingin melihat daftar pengaduan warga sewilayah kerja saya yang diurutkan berdasarkan skala prioritas (Priority Queue) dan mengklaim kasus tersebut agar dapat saya dampingi. | 1. Mendesain halaman utama (dashboard) Paralegal.<br>2. Mendesain kartu pengaduan (card) dengan visual tag prioritas (Urgensi Tinggi s.d Rendah).<br>3. Mendesain tombol "Ambil Kasus" (Claim Case) beserta dialog konfirmasi persetujuan penanganan. | 1. Membuat tampilan (*Slicing*) halaman utama paralegal & list kasus pengaduan.<br>2. Menghubungkan daftar pengaduan ke server (`GET /pengaduan`) agar memuat kasus sewilayah kelurahan yang sudah terurut prioritas.<br>3. Menghubungkan aksi tombol "Ambil Kasus" ke server (`PATCH /pengaduan/{id}/status` untuk set status 'diproses' dan mencatat id paralegal).<br>4. Memperbarui tampilan dashboard secara instan setelah kasus berhasil diambil. | **Sprint 2** |
| **PB04** | **Status Laporan & Riwayat Penanganan (Timeline)** | **Warga:**<br>Sebagai Warga, saya ingin memantau perkembangan kasus saya lewat halaman status laporan yang transparan.<br><br>**Paralegal:**<br>Sebagai Paralegal, saya ingin memperbarui riwayat penanganan kasus, menambahkan catatan progres, dan mengunggah dokumen kemajuan agar terdokumentasi dengan baik. | 1. Mendesain tampilan linimasa/timeline (Warga: *"Status Laporan Anda"*; Paralegal: *"Riwayat Penanganan Kasus"*).<br>2. Mendesain form input progres kasus bagi paralegal (tambah catatan, lampiran dokumen/foto, opsi tampilkan ke warga `is_visible`).<br>3. Mendesain status akhir kasus (Selesai/Ditolak/Dibatalkan) beserta input catatan penolakan/internal.<br>4. Mendesain layout penampil dokumen PDF bawaan (*In-App PDF Viewer*). | 1. Membuat tampilan (*Slicing*) halaman timeline kasus, form input progres, dan layar pembuka PDF.<br>2. Menghubungkan halaman timeline ke server untuk mengambil histori penanganan kasus (`GET /pengaduan/{id}/timeline`).<br>3. Menghubungkan form input progres paralegal ke server (`POST /pengaduan/{id}/timeline` beserta file lampiran).<br>4. Memasang library penampil berkas PDF internal (`flutter_pdfview`) agar dokumen laporan bisa dibaca langsung di dalam aplikasi.<br>5. Menghubungkan status penyelesaian kasus ke server (`status = selesai` / `dibatalkan` disertai catatan penutupan kasus). | **Sprint 3** |
| **PB05** | **Komunikasi & Chat Konsultasi** | **Warga & Paralegal:**<br>Sebagai Warga/Paralegal, saya ingin berkirim pesan teks dan media secara langsung per kasus agar konsultasi hukum berjalan responsif dan interaktif. | 1. Mendesain halaman daftar chat aktif (inbox).<br>2. Mendesain halaman percakapan chat room (bubble chat terpisah antara pengirim/penerima, status read/unread, dan attachment preview).<br>3. Mendesain panel input chat (tombol kirim, emoji, media picker). | 1. Membuat tampilan (*Slicing*) ruang chat dan daftar percakapan aktif.<br>2. Menghubungkan halaman chat ke server untuk mengambil pesan (`GET /chat/{id}`) dan mengirim pesan baru (`POST /chat/{id}`).<br>3. Mengaktifkan sistem pengiriman pesan real-time (bisa menggunakan metode *polling* berkala atau *WebSocket/Pusher*).<br>4. Memasang fitur kirim foto atau dokumen PDF langsung di dalam chat.<br>5. Menampilkan nama dan role (Warga/Paralegal) di bagian atas ruang percakapan. | **Sprint 4** |
| **PB06** | **Notifikasi Sistem** | **Warga & Paralegal:**<br>Sebagai Warga/Paralegal, saya ingin mendapatkan notifikasi real-time ketika ada pembaruan status aduan, pesan chat baru, atau status laporan kegiatan agar tidak tertinggal informasi. | 1. Mendesain halaman Pusat Notifikasi (Notification Center).<br>2. Mendesain kartu notifikasi (ikon kategori: pengaduan, chat, kegiatan, sistem) beserta penanda belum dibaca (unread).<br>3. Mendesain pop-up notifikasi melayang di dalam aplikasi (in-app banner). | 1. Membuat tampilan (*Slicing*) halaman notifikasi.<br>2. Menghubungkan daftar notifikasi ke server (`GET /notifikasi`) untuk mengambil pemberitahuan terbaru.<br>3. Menghubungkan aksi klik notifikasi ke server untuk menandai notifikasi sudah dibaca (`PUT /notifikasi/{id}/read`).<br>4. Memasang library notifikasi HP (seperti Firebase Cloud Messaging / FCM) agar pemberitahuan bisa muncul di status bar atas HP pengguna. | **Sprint 4** |
| **PB07** | **Laporan Kegiatan Lapangan (POV Paralegal)** | **Paralegal:**<br>Sebagai Paralegal, saya ingin membuat laporan kegiatan hukum lapangan (penyuluhan, pendampingan kelompok) dengan menyertakan foto, detail anggota, dan hasil kegiatan agar disetujui oleh admin web. | 1. Mendesain form input Laporan Kegiatan Lapangan (kategori, tgl mulai/selesai, anggota terlibat, lokasi, hasil kegiatan).<br>2. Mendesain modul pengambil & pengunggah foto (kamera & galeri).<br>3. Mendesain halaman Riwayat Kegiatan beserta label status verifikasi admin (Menunggu/Disetujui/Ditolak beserta catatan admin). | 1. Membuat tampilan (*Slicing*) form laporan kegiatan dan list riwayat kegiatan.<br>2. Menambahkan fitur pengambilan gambar langsung menggunakan kamera HP atau memilih dari galeri.<br>3. Menghubungkan form input kegiatan ke server (`POST /kegiatan`) dengan mengirim berkas gambar kegiatan beserta data anggota dalam format JSON.<br>4. Menghubungkan daftar riwayat kegiatan ke server (`GET /kegiatan`).<br>5. Membuat logika agar status approval admin dan alasan penolakan (`catatan_admin`) muncul jelas pada detail laporan kegiatan. | **Sprint 5** |

---

## 🛠️ Alur Koordinasi Agile UX per Iterasi (Sprint)

Untuk memastikan kolaborasi berjalan lancar, ikuti langkah berikut di setiap Sprint:

```
[Tahap UI/UX]                              [Tahap Development]
Desain User Flow ──> Mockup Hi-Fi Figma ──> Ekspor Aset & Slicing UI ──> Integrasi API ──> Testing & Review
```

1.  **Sesi Penyelarasan (Sprint Planning):** Kamu dan teman UI/UX menyepakati Backlog mana yang akan dikerjakan pada sprint ini.
2.  **Eksplorasi Desain:** Teman UI/UX membuat rancangan di Figma. Setelah kamu setuju dengan alur dan visualnya, kembangkan halaman tersebut.
3.  **Slicing & Pengkodean:** Kamu menerjemahkan desain Figma tersebut menjadi tampilan Flutter (*Slicing UI*) sambil mengekspor aset (ikon/gambar) dari Figma.
4.  **Koneksi Server & Pengujian:** Hubungkan ke database backend Laravel (*Integrasi API*), lalu uji bersama teman UI/UX (*Usability Testing* skala kecil) untuk memastikan tidak ada alur yang membingungkan atau visual yang rusak.
