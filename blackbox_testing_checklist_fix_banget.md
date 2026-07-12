# Panduan Uji Coba Blackbox (Blackbox Testing)
## Modul Pengaduan, Kelola Pengaduan, Chat Konsultasi, & Kegiatan Lapangan

Panduan ini berisi daftar skenario pengujian (Test Cases) untuk memverifikasi fungsionalitas dan responsivitas fitur sesuai dengan **Product Backlog 1 s.d 5, dan 7** yang telah kita selesaikan. 

Lakukan uji coba berikut menggunakan emulator atau perangkat HP langsung.

---

## 📌 Bagian 1: Pengajuan Pengaduan (POV Warga - PB02)

Masuk ke aplikasi menggunakan akun dengan peran **Warga**, lalu lakukan pengujian berikut:

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-01** | Responsivitas Formulir Pengaduan | 1. Buka menu **Buat Pengaduan**.<br>2. Perhatikan layout pada layar HP (portrait) dan tablet/layar lebar (jika ada). | Tampilan form rata tengah dengan lebar maksimal `650.0`. Input tidak melar/gepeng di tablet. | `[ ]` |
| **TC-02** | Validasi NIK (Nomor Induk Kependudukan) | 1. Ketik NIK kurang dari 16 digit (misal: `12345`).<br>2. Coba ketik huruf atau spasi.<br>3. Klik submit. | • Karakter huruf/spasi otomatis tertolak (hanya angka).<br>• Muncul snackbar error: *"NIK wajib 16 digit angka!"* | `[ ]` |
| **TC-03** | Indikator Progress Pengisian | 1. Perhatikan progress bar di bagian atas.<br>2. Isi kolom formulir satu per satu. | Progress bar bertambah secara visual (misal: `1/9 Lengkap` hingga `9/9 Lengkap`). | `[ ]` |
| **TC-04** | Pemilih Tanggal & Waktu Kejadian | 1. Tap input **Tanggal Kejadian**.<br>2. Tap input **Waktu Kejadian**. | • Membuka dialog kalender bawaan Flutter, tgl terpilih terformat rapi.<br>• Membuka dialog jam bawaan. | `[ ]` |
| **TC-05** | Pemilihan Jenis Masalah (Kategori) | 1. Tap input **Jenis Masalah**. | Membuka bottom sheet modal berisi daftar kategori aduan hukum, radio button berfungsi. | `[ ]` |
| **TC-06** | Pemilihan Berkas Bukti (File Picker) | 1. Tap tombol **Pilih Berkas**.<br>2. Pilih gambar (JPG/PNG) atau PDF.<br>3. Coba pilih file berukuran > 5 MB. | • File < 5 MB terlampir di daftar berkas.<br>• File > 5 MB memicu snackbar peringatan dan diabaikan. | `[ ]` |
| **TC-07** | Pengiriman Form & Halaman Sukses | 1. Lengkapi form hingga `9/9 Lengkap`.<br>2. Tap **Kirim Pengaduan**. | • Loading indicator aktif.<br>• Navigasi otomatis ke halaman Sukses.<br>• Menampilkan kode tiket (ID Pengaduan) yang benar (contoh: `PGN-2026-12345`). | `[ ]` |
| **TC-08** | Salin ID Pengaduan & Navigasi Detail | 1. Tap area ID Pengaduan pada halaman sukses.<br>2. Tap tombol **Lihat Detail Pengaduan**. | • Muncul notifikasi *"ID Pengaduan disalin"*.<br>• Masuk ke halaman **Detail Kasus** warga menggunakan UUID dari database. | `[ ]` |
| **TC-09** | Filter & Pencarian Daftar Pengaduan | 1. Masuk ke halaman **Pengaduan Saya**.<br>2. Tap tab **Semua / Proses / Selesai**.<br>3. Ketik kata kunci di kolom pencarian. | • Daftar terfilter secara instan.<br>• Pencarian berfungsi menyaring berdasarkan judul atau ID tiket. | `[ ]` |
| **TC-10** | Pull to Refresh | 1. Tarik daftar pengaduan ke bawah. | Memicu animasi loading melingkar dan memuat ulang data terbaru dari server Laravel. | `[ ]` |

---

## 📌 Bagian 2: Manajemen Kasus Masuk (POV Paralegal - PB03)

Keluar dari akun warga, lalu masuk menggunakan akun **Paralegal** untuk menguji dashboard pengelolaan:

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-11** | Sinkronisasi Wilayah Tugas | 1. Masuk ke Dashboard Utama Paralegal.<br>2. Perhatikan daftar kasus yang muncul. | Hanya memuat pengaduan warga yang berasal dari wilayah Kelurahan tugas paralegal tersebut. | `[ ]` |
| **TC-12** | Urutan Skala Prioritas (Priority Queue) | 1. Perhatikan urutan daftar pengaduan. | Kasus dengan tingkat prioritas tinggi (misal: *Kejahatan Seksual / Sangat Tinggi*) berada di paling atas. | `[ ]` |
| **TC-13** | Visualisasi Skala Prioritas & Status | 1. Cek warna tag prioritas.<br>2. Cek warna badge status aduan. | Urgensi ditampilkan dengan tag berwarna kontras (Merah: Sangat Tinggi, Kuning: Sedang, dll). | `[ ]` |
| **TC-14** | Paginasi & Lazy Loading List Kasus | 1. Scroll daftar kasus ke bawah secara kontinu hingga mencapai baris akhir halaman pertama. | Muncul indikator loading di bawah, lalu otomatis memuat data halaman berikutnya (Lazy Loading). | `[ ]` |
| **TC-15** | Pengambilan Kasus (Claim Case) | 1. Pilih kasus berstatus **Menunggu**.<br>2. Tap tombol **Proses Kasus / Ambil Kasus**. | • Muncul dialog konfirmasi GetX.<br>• Ketika diklik "Ya", status kasus berubah menjadi "diproses" dan terdaftar di tab proses paralegal. | `[ ]` |

---

## 📌 Bagian 3: Status Laporan & Linimasa/Timeline (PB04)

Skenario uji untuk memantau transparansi progres kasus dari kedua sisi (Warga & Paralegal):

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-16** | Pembatalan Kasus oleh Warga | 1. Login sebagai Warga.<br>2. Buka detail pengaduan berstatus **Pending / Menunggu**.<br>3. Tap **Batalkan Pengaduan**.<br>4. Konfirmasi pada dialog pop-up. | • Kasus dibatalkan.<br>• Linimasa bertambah poin *"Pengaduan Dibatalkan"*.<br>• Tombol batalkan menghilang. | `[ ]` |
| **TC-17** | Pembukaan Dokumen Lampiran (Warga) | 1. Masuk ke detail kasus.<br>2. Tap berkas Bukti awal berbentuk **Gambar**.<br>3. Tap berkas berbentuk **PDF**. | • Gambar terbuka fullscreen dengan kemampuan zoom (InteractiveViewer).<br>• PDF terunduh dan terbuka rapi di pemutar internal (*In-App PDF Viewer*). | `[ ]` |
| **TC-18** | Form Update Progres oleh Paralegal | 1. Login sebagai Paralegal.<br>2. Buka detail kasus aktif.<br>3. Tap **Update Progres**.<br>4. Isi formulir progres (catatan, status baru, lampiran foto/file).<br>5. Klik Kirim & Konfirmasi. | • Data terkirim secara Multipart ke backend.<br>• Status kasus terupdate di server.<br>• Paralegal diarahkan kembali ke detail dengan progres terbaru yang sudah tercatat. | `[ ]` |
| **TC-19** | Sinkronisasi Real-Time Linimasa Warga | 1. Login kembali sebagai Warga.<br>2. Buka kasus yang di-update oleh Paralegal pada TC-18. | Poin histori linimasa bertambah sesuai catatan progres yang dimasukkan paralegal (misal: *"Menyerahkan berkas gugatan ke Pengadilan"*). | `[ ]` |

---

## 📌 Bagian 4: Autentikasi & Manajemen Akun (PB01)

Skenario uji coba untuk memverifikasi fungsionalitas Google Sign-In, kelengkapan data profil warga, serta tata letak responsif:

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-20** | Registrasi & Login Warga via Google | 1. Di halaman masuk, tap tombol **Masuk dengan Google / Daftar dengan Google**.<br>2. Pilih akun Google baru/belum terdaftar. | • Login berhasil.<br>• Pengguna diarahkan ke Dashboard Warga.<br>• Backend otomatis mendaftarkan pengguna baru dengan peran `warga`. | `[ ]` |
| **TC-21** | Login Google Akun Paralegal | 1. Siapkan email akun Paralegal yang telah dibuat oleh Admin di web.<br>2. Di aplikasi mobile, tap **Masuk dengan Google**.<br>3. Pilih akun Google dengan email Paralegal tersebut. | • Login berhasil.<br>• Sistem mendeteksi peran sebagai `paralegal` berdasarkan email yang cocok.<br>• Pengguna diarahkan ke Dashboard Paralegal. | `[ ]` |
| **TC-22** | Deteksi Kelengkapan Profil (Dashboard Warga) | 1. Login sebagai Warga baru.<br>2. Masuk ke tab Beranda/Dashboard Warga. | Muncul kartu peringatan (Warning Card) berwarna biru gelap bertuliskan **"Profil Belum Lengkap"** dengan tombol **"Lengkapi Sekarang"**. | `[ ]` |
| **TC-23** | Lengkapi Profil Warga (Dropdown Wilayah) | 1. Buka halaman **Edit Profil** Warga.<br>2. Tap dropdown **Kabupaten / Kota**, pilih salah satu.<br>3. Tap dropdown **Kecamatan**, lalu **Kelurahan**.<br>4. Masukkan alamat tinggal.<br>5. Tap **Simpan Perubahan**. | • Pilihan kecamatan disaring dinamis setelah kabupaten dipilih.<br>• Pilihan kelurahan disaring dinamis setelah kecamatan dipilih.<br>• Data berhasil disimpan dan kartu peringatan di Dashboard Warga otomatis menghilang. | `[ ]` |
| **TC-24** | Validasi Kolom NIK (Profil Warga) | 1. Di form edit profil warga, coba masukkan NIK dengan jumlah digit selain 16.<br>2. Klik **Simpan**. | • Jumlah karakter ditampilkan secara real-time (format `X/16`).<br>• Muncul snackbar error dari validasi frontend jika NIK tidak tepat 16 digit. | `[ ]` |
| **TC-25** | Perbarui Foto Profil & Nomor Telepon | 1. Di form edit profil (Warga/Paralegal), tap ikon kamera.<br>2. Pilih foto dari galeri.<br>3. Ubah nomor telepon.<br>4. Tap **Simpan**. | • Indikator loading aktif saat mengunggah.<br>• Foto profil dan nomor telepon terupdate di halaman profil utama secara instan. | `[ ]` |
| **TC-26** | Responsivitas Keyboard Halaman Masuk | 1. Buka halaman Login/Register.<br>2. Munculkan keyboard virtual HP. | Tampilan dapat di-scroll dengan lancar menggunakan `SingleChildScrollView` dan tidak terjadi layout overflow / garis kuning-hitam. | `[ ]` |
| **TC-27** | Peniadaan Fitur Password Lokal & Logout Aman | 1. Buka halaman edit profil (Warga & Paralegal).<br>2. Perhatikan bagian bawah form.<br>3. Lakukan logout dari aplikasi. | • **Tidak ada** label atau kartu "Ubah Password" (Keamanan) karena login menggunakan Google OAuth.<br>• Logout berhasil, sesi local storage dibersihkan, dan kembali ke halaman Welcome. | `[ ]` |

---

## 📌 Bagian 5: Komunikasi & Chat Konsultasi (PB05)

Skenario uji coba untuk memverifikasi fungsionalitas chat real-time, polling 3 detik, deteksi unread, pengiriman media, dan halaman informasi chat:

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-28** | Masuk ke Ruang Obrolan | 1. Login sebagai Warga.<br>2. Buka detail pengaduan aktif (`diproses`).<br>3. Tap tombol **Hubungi Pendamping / Paralegal**. | • Berhasil membuka halaman Detail Chat.<br>• Header menampilkan nama Paralegal pendamping secara dinamis.<br>• Memuat riwayat obrolan terdahulu jika ada. | `[x]` |
| **TC-29** | Pengiriman & Penentuan Posisi Pesan (Sender Bubble) | 1. Ketik pesan teks di chat input.<br>2. Kirim pesan. | • Pesan terkirim ke server Laravel.<br>• Pesan pengirim (Warga/Paralegal sendiri) dirender di sisi kanan (bubble gelap).<br>• Pesan penerima dirender di sisi kiri (bubble putih/avatar klien). | `[x]` |
| **TC-30** | Polling Otomatis 3 Detik (Real-time Message) | 1. Buka layar chat di HP Warga dan HP Paralegal secara bersamaan.<br>2. Kirim pesan dari HP Paralegal ke Warga. | • Tanpa refresh manual, pesan dari Paralegal otomatis terender di HP Warga dalam waktu maksimal 3 detik.<br>• Halaman chat otomatis scroll ke bawah (auto-scroll) setiap ada pesan baru masuk. | `[x]` |
| **TC-31** | Indikator Pesan Belum Dibaca (Unread Highlight) | 1. Kirim pesan dari sisi lawan bicara ke akun yang sedang diuji.<br>2. Perhatikan item chat di daftar obrolan. | • Muncul **garis biru setebal 4px** di sisi kiri card.<br>• Waktu pesan terakhir berwarna biru.<br>• Muncul badge bulat biru berisi jumlah pesan belum dibaca. | `[x]` |
| **TC-32** | Tampilan Jam Terkirim (WhatsApp Style) | 1. Perhatikan posisi jam pada gelembung obrolan pengirim dan penerima. | Jam terkirim berada di dalam bubble chat, merapat rapi di kanan bawah teks obrolan. | `[x]` |
| **TC-33** | Halaman Informasi Chat Posbankum (POV Warga) | 1. Login sebagai Warga.<br>2. Masuk ke ruang chat, tap ikon menu/info di kanan atas header. | Masuk ke halaman **Info Chat Posbankum** yang menampilkan nama Kelurahan/Posbankum, kontak telepon, alamat, peta lokasi, dan jadwal layanan. | `[x]` |
| **TC-34** | Halaman Informasi Chat Warga (POV Paralegal) | 1. Login sebagai Paralegal.<br>2. Masuk ke ruang chat, tap ikon menu/info di kanan atas header. | Masuk ke halaman **Info Chat Warga** yang menampilkan NIK klien, nama, email, nomor HP, dan alamat detail klien. | `[x]` |
| **TC-35** | Pengiriman Lampiran Berkas Media Chat | 1. Tap tombol plus (+) di bagian input.<br>2. Pilih **Pilih Dokumen (PDF)** atau **Gambar**.<br>3. Pilih berkas dan kirim. | • Media terunggah via Multipart ke `/pengaduan/{id}/lampiran` dengan `jenis_lampiran = 'chat'`.<br>• Pesan dikirim berformat khusus: `[FILE]nama_file.ext\|secure_url`. | `[x]` |
| **TC-36** | Pratinjau Gambar & Pembuka PDF Chat | 1. Di ruang chat, tap bubble media gambar.<br>2. Tap bubble media dokumen PDF. | • Gambar terbuka fullscreen dengan mode cubit-zoom.<br>• PDF langsung terunduh via header secure token (tanpa terhalang 401 redirect) dan tampil di layar `PdfViewerScreen` internal. | `[x]` |

---

## 📌 Bagian 6: Laporan Kegiatan Lapangan (POV Paralegal - PB07)

Skenario uji untuk memvalidasi fungsionalitas manajemen laporan kegiatan lapangan paralegal (Penyuluhan, Sosialisasi, Bimbingan):

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-37** | Navigasi Halaman Daftar Kegiatan | 1. Login sebagai Paralegal.<br>2. Buka tab/menu **Kegiatan**. | • Masuk ke halaman **Kelola Kegiatan**.<br>• Header melengkung dengan gambar ilustrasi gedung.<br>• Tampilan ter-constraint maksimal `650.0` pada layar lebar/tablet. | `[x]` |
| **TC-38** | Pencarian & Filter Kegiatan | 1. Ketik kata kunci pada Search Bar.<br>2. Tap tombol filter tanggal (ikon kalender) di kanan search bar.<br>3. Pilih tanggal di kalender modal. | • Daftar kegiatan menyaring secara instan berdasarkan judul/lokasi.<br>• Judul bagian list berubah format (contoh: *DAFTAR KEGIATAN: JULI 2026*).<br>• Tap lagi tombol kalender untuk mereset filter tanggal. | `[x]` |
| **TC-39** | Tambah Kegiatan Baru (Form Validation & Simpan) | 1. Tap tombol **Mulai buat Laporan kegiatan**.<br>2. Masukkan judul, tanggal pelaksanaan, lokasi, deskripsi, dan hasil kegiatan.<br>3. Pastikan input hasil kegiatan berbentuk text area (teks melipat ke bawah saat panjang).<br>4. Tap unggah gambar cover, pilih foto (kamera/galeri).<br>5. Perhatikan warna tombol Simpan Kegiatan (berwarna biru tua `0xFF2A2E5E`).<br>6. Tap **Simpan Kegiatan**. | • Validasi mewajibkan judul, tanggal, lokasi, dan gambar cover.<br>• Field jumlah peserta dan anggota terlibat ditiadakan (nama pelapor terisi otomatis dari user login).<br>• Sukses mengunggah ke database server via Multipart, dan status awal kegiatan diset ke **MENUNGGU**. | `[x]` |
| **TC-40** | Tampilan Detail Laporan Kegiatan | 1. Tap salah satu kegiatan di list Kelola Kegiatan.<br>2. Perhatikan detail informasi yang ditampilkan. | • Layout detail rapi, cover gambar tampil jernih via normalisasi HTTPS.<br>• Di bawah judul utama menampilkan nama Posbankum dan regional penugasan (*Nama Posbankum • Kecamatan, Kabupaten*).<br>• Menampilkan status (badge), tanggal, lokasi, nama pelapor beserta instansi posbankum, deskripsi, dan hasil kegiatan.<br>• Tombol **Edit Kegiatan** dan **Bagikan Detail** tersedia di bagian bawah detail. | `[x]` |
| **TC-41** | Edit Laporan Kegiatan | 1. Di detail kegiatan, tap **Edit Kegiatan**.<br>2. Form edit menampilkan data awal kegiatan dengan layout header melengkung berlatar gambar.<br>3. Ubah beberapa isian form (misal: deskripsi, hasil kegiatan pada input text area).<br>4. Klik **Simpan Kegiatan** (tombol berwarna biru tua `0xFF2A2E5E`). | Data terupdate secara instan di server Laravel, dan status kegiatan diset ulang kembali ke **MENUNGGU** (untuk verifikasi ulang admin). | `[x]` |
| **TC-42** | Bagikan Detail Kegiatan (PDF/Teks) | 1. Di detail kegiatan, tap **Bagikan Detail**.<br>2. Pilih **Bagikan Teks** untuk membagikan info teks.<br>3. Pilih **Bagikan Gambar PDF** untuk mencetak tampilan detail menjadi PDF. | • Berhasil membagikan teks ringkasan kegiatan ke aplikasi lain.<br>• Berhasil memotret tampilan detail dan menyimpannya sebagai berkas PDF (A4) untuk dibagikan secara instan. | `[x]` |
| **TC-43** | Penampilan Alasan Penolakan (Catatan Admin) | 1. Buka detail kegiatan yang berstatus **DITOLAK**.<br>2. Perhatikan bagian bawah rincian. | Muncul kartu berwarna merah terang bertuliskan **Catatan Admin** yang berisi detail alasan penolakan dari admin website. | `[x]` |

---

## 📌 Bagian 7: Notifikasi Sistem & Push Notification (Sprint 4 - PB06)

Skenario uji untuk memvalidasi fungsionalitas notifikasi sistem in-app serta integrasi Firebase Cloud Messaging (FCM) dan Local Notifications dengan suara kustom:

| No. Test | Skenario Uji Coba | Langkah-Langkah | Hasil yang Diharapkan | Status |
| :--- | :--- | :--- | :--- | :---: |
| **TC-44** | Halaman Notifikasi In-App Warga (POV Warga) | 1. Login sebagai Warga.<br>2. Buka tab **Notifikasi** (ikon lonceng) di bottom navigation bar. | • Halaman menampilkan daftar notifikasi khusus warga.<br>• Tersedia filter chip: **Semua**, **Belum Dibaca**, dan **Sudah Dibaca**.<br>• Desain premium dengan header melengkung berlatar gambar gedung.<br>• Indikator belum dibaca (badge bulat biru) tampil jelas di item. | `[ ]` |
| **TC-45** | Halaman Notifikasi In-App Paralegal (POV Paralegal) | 1. Login sebagai Paralegal.<br>2. Tap ikon lonceng di kanan atas header beranda (dashboard). | • Navigasi lancar masuk ke halaman **Notifikasi Masuk**.<br>• Tersedia tombol kembali (Back arrow) di kiri atas header.<br>• Daftar notifikasi tersaring berdasarkan Posbankum paralegal. | `[ ]` |
| **TC-46** | Tandai Baca Notifikasi & Navigasi Cepat (Deep Linking) | 1. Tap salah satu item notifikasi kategori "pengaduan" atau "kegiatan" yang belum dibaca. | • Notifikasi berubah status menjadi dibaca di server (is_read = 1) dan secara visual (background biru muda memudar).<br>• Aplikasi otomatis mengarahkan (deep link) ke halaman Detail Kasus (Warga/Paralegal) atau Detail Kegiatan. | `[ ]` |
| **TC-47** | Tandai Semua Dibaca (Mark All Read) | 1. Di halaman notifikasi, klik tombol ikon centang ganda (done all) di kanan atas bar filter. | • Seluruh notifikasi yang terdaftar di halaman otomatis berubah status menjadi dibaca (is_read = 1) di database dan visual. | `[ ]` |
| **TC-48** | Push Notification FCM & Suara Kustom (Android/iOS) | 1. Kirim push payload via Firebase Console / POST request ke device token.<br>2. Uji pada state: Foreground (app aktif), Background (app diminimize), Terminated (app ditutup). | • Banner notifikasi muncul instan di bar status HP.<br>• Notifikasi berbunyi menggunakan suara kustom (`notif_sound.mp3`).<br>• Ketika banner notifikasi ditap, aplikasi otomatis terbuka dan langsung masuk ke ruang chat (jika notif chat) atau detail target (deep link). | `[ ]` |
