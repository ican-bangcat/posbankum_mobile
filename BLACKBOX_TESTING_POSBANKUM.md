# DOKUMEN PENGUJIANKELAS DAN SKENARIO UJI (BLACK BOX TESTING)
## SISTEM APLIKASI POSBANKUM BERDAMPAK (SIBAPAK) - MODUL MOBILE

---

## 📋 DAFTAR ISI

*   **1. PENDAHULUAN & METODOLOGI**
*   **2. HASIL PENGUJIEN BLACK BOX TESTING PER SPRINT**
    *   **2.1 Sprint 1:** Autentikasi, Profil & Pengajuan Pengaduan
    *   **2.2 Sprint 2:** Manajemen Kasus Masuk & Prioritas (POV Paralegal)
    *   **2.3 Sprint 3:** Status Laporan & Riwayat Penanganan (Timeline)
    *   **2.4 Sprint 4:** Laporan Kegiatan Lapangan (POV Paralegal)
    *   **2.5 Sprint 5:** Komunikasi Chat & Notifikasi Sistem (Pasca Sempro)
    *   **2.6 Sprint 6:** Penambahan Lampiran Progres & UAT Refinement
*   **3. REKAPITULASI HASIL PENGUJIAN BLACK BOX**

---

## 1. PENDAHULUAN & METODOLOGI

Dokumen ini berisi catatan pengujian perangkat lunak menggunakan metode **Black Box Testing** untuk aplikasi mobile **SIBAPAK (Posbankum Berdampak)**. 

Pengujian *Black Box* berfokus pada pengujian persyaratan fungsionalitas aplikasi tanpa melihat struktur kode internal program. Pengujian dilakukan secara iteratif pada setiap akhir **Sprint (Sprint 1 s.d. Sprint 6)**. Sebuah kartu fitur (*card*) pada Trello Board pengerjaan proyek baru diperbolehkan dipindahkan ke kolom **DONE** setelah seluruh skenario pengujian *Black Box* pada Sprint bersangkutan dinyatakan **[*] Berhasil**.

---

## 2. HASIL PENGUJIAN BLACK BOX TESTING PER SPRINT

### 2.1 Sprint 1: Autentikasi, Profil & Pengajuan Pengaduan
**Periode / Target:** Membangun sistem login Google OAuth, manajemen profil warga (domisili Riau), dan pengajuan pengaduan baru.

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 1 | *Onboarding* | Pada halaman awal aplikasi, geser slide intro ke kiri lalu ketuk tombol **Mulai**. | Menampilkan layar masuk (*Welcome Screen*) aplikasi. | [*] Berhasil<br>[ ] Gagal |
| 2 | *Login Warga* | Pada halaman login, ketuk tombol **Daftar/Login dengan Google** dan pilih akun Google valid. | Sistem berhasil mengautentikasi dan menampilkan halaman Beranda Warga. | [*] Berhasil<br>[ ] Gagal |
| 3 | *Session Management* | Buka kembali aplikasi SIBAPAK dalam posisi akun telah terautentikasi sebelumnya. | Aplikasi langsung membuka Beranda Warga tanpa meminta login ulang. | [*] Berhasil<br>[ ] Gagal |
| 4 | *Logout Akun* | Pada halaman profil pengguna, ketuk tombol **Logout** dan konfirmasi keluar. | Sesi login terhapus dari memori HP dan aplikasi kembali ke layar Login. | [*] Berhasil<br>[ ] Gagal |
| 5 | *Warning Profil* | Login menggunakan akun Warga baru yang belum mengisi data domisili. | Menampilkan kartu peringatan "Profil Belum Lengkap" di bagian atas Beranda. | [*] Berhasil<br>[ ] Gagal |
| 6 | *Profil Domisili* | Pada form edit profil, pilih Wilayah Riau (Kabupaten, Kecamatan, Kelurahan) dan isi alamat. | Dropdown saringan wilayah berfungsi dinamis dan data profil berhasil disimpan. | [*] Berhasil<br>[ ] Gagal |
| 7 | *Validasi NIK* | Pada form edit profil, masukkan NIK berjumlah kurang dari 16 digit angka (misal: 12 digit). | Menampilkan pesan error *snackbar* "NIK wajib 16 digit angka!" dan batal menyimpan. | [*] Berhasil<br>[ ] Gagal |
| 8 | *Form Pengaduan* | Pada halaman form aduan, isi kronologi, lokasi kejadian, dan lampirkan file foto/PDF bukti awal. | Pengaduan berhasil terkirim ke server (`POST /pengaduan`) dan terdaftar di beranda. | [*] Berhasil<br>[ ] Gagal |
| 9 | *Validasi Aduan* | Pada form aduan, kosongkan kolom judul dan kronologi kejadian lalu ketuk **Kirim**. | Menampilkan peringatan bahwa kolom wajib diisi dan pengaduan tidak terkirim. | [*] Berhasil<br>[ ] Gagal |

---

### 2.2 Sprint 2: Manajemen Kasus Masuk & Prioritas (POV Paralegal)
**Periode / Target:** Membangun dashboard paralegal, daftar kasus sewilayah, pengurutan skala prioritas (*Priority Queue*), dan aksi pengklaiman kasus.

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 10 | *Login Paralegal* | Pada halaman login, masuk menggunakan akun Google dengan email terdaftar Admin. | Menampilkan halaman Beranda Paralegal khusus wilayah kerjanya. | [*] Berhasil<br>[ ] Gagal |
| 11 | *List Kasus Masuk* | Buka tab **Kasus Masuk** pada dashboard Paralegal. | Menampilkan daftar aduan warga terurut berdasarkan prioritas urgensi kasus. | [*] Berhasil<br>[ ] Gagal |
| 12 | *Klaim Kasus* | Pada kartu pengaduan status 'menunggu', ketuk tombol **Ambil Kasus**. | Status aduan di database berubah menjadi `diproses` dan ID paralegal tercatat. | [*] Berhasil<br>[ ] Gagal |
| 13 | *Update Dashboard* | Amati statistik beranda paralegal setelah kasus berhasil diklaim. | Jumlah kasus 'Sedang Diproses' bertambah secara instan tanpa perlu restart app. | [*] Berhasil<br>[ ] Gagal |
| 14 | *Akses Detail Kasus* | Ketuk salah satu kartu kasus pada daftar pengaduan. | Menampilkan detail lengkap informasi pelapor, kronologi kejadian, dan bukti awal. | [*] Berhasil<br>[ ] Gagal |

---

### 2.3 Sprint 3: Status Laporan & Riwayat Penanganan (Timeline)
**Periode / Target:** Membangun linimasa perkembangan kasus harian (*timeline*), input progres paralegal, penutupan kasus, dan penampil PDF internal.

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 15 | *Monitoring Timeline* | Buka detail kasus aktif dari sisi Warga maupun Paralegal. | Menampilkan urutan linimasa (*timeline*) riwayat penanganan kasus harian. | [*] Berhasil<br>[ ] Gagal |
| 16 | *Input Progres* | Pada halaman detail kasus paralegal, ketuk **Update Progres**, isi judul & catatan harian. | Catatan progres baru berhasil tersimpan (`POST /pengaduan/{id}/timeline`). | [*] Berhasil<br>[ ] Gagal |
| 17 | *Selesaikan Kasus* | Pada form update progres atau dialog penutupan, isi catatan akhir dan pilih **Selesaikan Kasus**. | Status pengaduan berubah menjadi `selesai` dan linimasa penyelesaian tercatat. | [*] Berhasil<br>[ ] Gagal |
| 18 | *Tolak / Batalkan Kasus*| Pada dialog penutupan kasus, masukkan alasan penolakan dan ketuk **Tolak Kasus**. | Status pengaduan berubah menjadi `dibatalkan` dan alasan penolakan tersimpan. | [*] Berhasil<br>[ ] Gagal |
| 19 | *In-App PDF Viewer* | Pada detail pengaduan, ketuk berkas lampiran yang berformat `.pdf`. | Berkas PDF terunduh ke memori temporer dan terbuka lancar di dalam aplikasi. | [*] Berhasil<br>[ ] Gagal |

---

### 2.4 Sprint 4: Laporan Kegiatan Lapangan (POV Paralegal)
**Periode / Target:** Membangun modul formulir pelaporan kegiatan hukum lapangan (penyuluhan/sosialisasi) beserta bukti foto dan riwayat persetujuan admin.

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 20 | *Form Tambah Kegiatan*| Isi judul kegiatan, lokasi, tanggal, daftar anggota, hasil kegiatan, dan foto dokumentasi. | Laporan kegiatan berhasil terkirim ke server (`POST /kegiatan`) dengan status 'menunggu'. | [*] Berhasil<br>[ ] Gagal |
| 21 | *Upload Foto Kamera/Galeri*| Ketuk wadah pengunggah foto kegiatan, pilih opsi Kamera HP atau Galeri. | Foto terpilih dari kamera atau galeri berhasil tampil pada pratinjau form. | [*] Berhasil<br>[ ] Gagal |
| 22 | *Validasi Ukuran Foto*| Unggah foto dokumentasi kegiatan yang ukurannya melebihi 5 MB. | Menampilkan snackbar peringatan bahwa ukuran berkas melebihi batas 5 MB. | [*] Berhasil<br>[ ] Gagal |
| 23 | *Riwayat Kegiatan* | Buka menu **Riwayat Kegiatan** pada panel Paralegal. | Menampilkan daftar laporan kegiatan beserta label status verifikasi admin web. | [*] Berhasil<br>[ ] Gagal |

---

### 2.5 Sprint 5: Komunikasi Chat & Notifikasi Sistem (Pasca Sempro)
**Periode / Target:** Membangun ruang obrolan (*Chat Room*) konsultasi hukum per kasus dan Pusat Notifikasi real-time via Firebase Cloud Messaging (FCM).

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 24 | *Kirim Pesan Teks Chat*| Ketik pesan di kolom input obrolan kasus dan ketuk tombol **Kirim**. | Pesan terkirim ke server (`POST /chat/{id}`) dan muncul pada *bubble chat* pengirim. | [*] Berhasil<br>[ ] Gagal |
| 25 | *Kirim Lampiran Chat* | Ketuk ikon lampiran di ruang chat, pilih file gambar atau PDF. | File terunggah dan pratinjau media muncul di dalam gelembung obrolan chat. | [*] Berhasil<br>[ ] Gagal |
| 26 | *Daftar Chat (Inbox)* | Buka menu utama **Pesan / Chat**. | Menampilkan daftar percakapan aktif berisikan nama lawan bicara & pesan terakhir. | [*] Berhasil<br>[ ] Gagal |
| 27 | *Notifikasi Push FCM* | Simulasikan pembaruan status kasus atau pengiriman pesan baru dari sisi lain. | Notifikasi banner melayang (*Push Notification*) muncul di status bar HP. | [*] Berhasil<br>[ ] Gagal |
| 28 | *Auto-Refresh Notif* | Buka halaman Pusat Notifikasi tanpa melakukan *pull-to-refresh* manual. | Layar otomatis mengambil notifikasi paling hangat (*post frame callback*). | [*] Berhasil<br>[ ] Gagal |
| 29 | *Tanda Notif Dibaca* | Ketuk salah satu item pemberitahuan yang belum dibaca (*unread*). | Notifikasi berubah status menjadi dibaca (`is_read = 1`) & penanda merah hilang. | [*] Berhasil<br>[ ] Gagal |

---

### 2.6 Sprint 6: Penambahan Lampiran Progres & UAT Refinement
**Periode / Target:** Mengimplementasikan perbaikan UAT (Autofill NIK, Nama Lurah opsional, Lampiran Progres Kasus, Bottom Sheet, & perbaikan visual).

| No | Kelas Uji | Skenario Uji | Hasil yang Diharapkan | Hasil |
| :-: | :--- | :--- | :--- | :---: |
| 30 | *Autofill NIK & No HP* | Buka formulir pengaduan baru dari akun Warga yang profilnya sudah lengkap. | Kolom NIK dan Nomor Telepon otomatis terisi dari profil (tetap bisa diedit). | [*] Berhasil<br>[ ] Gagal |
| 31 | *Nama Lurah Opsional* | Pada form pengaduan, kosongkan kolom Nama Lurah lalu kirim aduan. | Form berhasil terkirim tanpa error (hanya 8 data wajib yang diperiksa). | [*] Berhasil<br>[ ] Gagal |
| 32 | *Upload Lampiran Progres*| Paralegal memilih 1 atau beberapa file foto/PDF pada form Update Progres. | Berkas terunggah & terikat dengan `id_timeline` baru di database. | [*] Berhasil<br>[ ] Gagal |
| 33 | *Chip Indikator Lampiran*| Amati item linimasa kasus yang memiliki berkas lampiran progres. | Menampilkan chip interaktif bertuliskan `📎 X File Lampiran • Klik untuk lihat`. | [*] Berhasil<br>[ ] Gagal |
| 34 | *Bottom Sheet Lampiran*| Ketuk chip indikator lampiran pada linimasa kasus. | Menampilkan *Bottom Sheet Modal* berisi grid thumbnail foto/PDF lampiran progres. | [*] Berhasil<br>[ ] Gagal |
| 35 | *Tombol Close Image Viewer*| Buka berkas lampiran foto yang latar belakang gambarnya berwarna putih bersih. | Tombol penutup (`X`) dalam lingkaran gelap & border putih tetap terlihat kontras. | [*] Berhasil<br>[ ] Gagal |
| 36 | *Pilihan Tanggal Progres*| Buka form Update Progres Pendampingan. | Kolom tanggal tidak otomatis terisi hari ini; menampilkan `"Pilih Tanggal Pendampingan"`. | [*] Berhasil<br>[ ] Gagal |
| 37 | *Warna Tombol Selesaikan*| Amati tombol aksi penyelesaian kasus pada form Update Progres. | Tombol tampil menggunakan warna **Hijau Solid (`#10B981`)** dengan teks putih tebal. | [*] Berhasil<br>[ ] Gagal |

---

## 3. REKAPITULASI HASIL PENGUJIAN BLACK BOX

Berikut adalah ringkasan hasil pengujian *Black Box Testing* dari Sprint 1 sampai Sprint 6:

| Iterasi Sprint | Jumlah Kasus Uji | Berhasil | Gagal | Persentase Keberhasilan | Status Kelayakan |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Sprint 1** | 9 Skenario | 9 | 0 | **100%** | **Lulus / Ready for Done** |
| **Sprint 2** | 5 Skenario | 5 | 0 | **100%** | **Lulus / Ready for Done** |
| **Sprint 3** | 5 Skenario | 5 | 0 | **100%** | **Lulus / Ready for Done** |
| **Sprint 4** | 4 Skenario | 4 | 0 | **100%** | **Lulus / Ready for Done** |
| **Sprint 5** | 6 Skenario | 6 | 0 | **100%** | **Lulus / Ready for Done** |
| **Sprint 6** | 8 Skenario | 8 | 0 | **100%** | **Lulus / Ready for Done** |
| **TOTAL** | **37 Skenario** | **37** | **0** | **100%** | **SISTEM SIBAPAK SANGAT LAYAK** |

---
*Dokumen ini disusun sebagai lampiran bukti pengujian fungsionalitas aplikasi mobile SIBAPAK dalam Laporan Proyek Akhir.*
